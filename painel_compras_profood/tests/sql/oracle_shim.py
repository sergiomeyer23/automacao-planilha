"""Executa o SQL GERADO (dialeto Oracle) num DuckDB em memória, para testar a LÓGICA das consultas
contra fixtures. NÃO é Oracle: diferenças conhecidas estão em RESULTADO_TESTES.md.

O shim só traduz o subconjunto de funções que o painel usa:
  NVL, TO_NUMBER, TO_DATE('YYYY-MM-DD'), ADD_MONTHS, TRUNC(data) / TRUNC(data,'MM'),
  TO_CHAR(data, formato), SYSDATE (fixado), DUAL e binds '?' (substituídos por literais, na ordem).
Qualquer construção fora disso falha no DuckDB, o que também serve de alerta.
"""
import json
import re

import duckdb

ESQUEMA = {
    "TGFCAB": [("NUNOTA", "BIGINT"), ("CODEMP", "INTEGER"), ("CODTIPOPER", "INTEGER"), ("DHTIPOPER", "TIMESTAMP"),
               ("DTNEG", "TIMESTAMP"), ("DTPREVENT", "TIMESTAMP"), ("STATUSNOTA", "VARCHAR"), ("CODPARC", "INTEGER"),
               ("AD_OSTUICIAL", "VARCHAR")],
    "TGFITE": [("NUNOTA", "BIGINT"), ("SEQUENCIA", "INTEGER"), ("CODPROD", "INTEGER"), ("QTDNEG", "DOUBLE"),
               ("CODVOL", "VARCHAR"), ("VLRTOT", "DOUBLE"), ("VLRUNIT", "DOUBLE"), ("QTDENTREGUE", "DOUBLE"),
               ("QTDCONFERIDA", "DOUBLE"), ("PENDENTE", "VARCHAR"), ("CANCELADO", "VARCHAR"), ("AD_OS", "VARCHAR")],
    "TGFPRO": [("CODPROD", "INTEGER"), ("DESCRPROD", "VARCHAR"), ("REFERENCIA", "VARCHAR"), ("CODVOL", "VARCHAR"),
               ("MARCA", "VARCHAR"), ("CODGRUPOPROD", "INTEGER"), ("ATIVO", "VARCHAR"), ("LEADTIME", "INTEGER"),
               ("ESTMIN", "DOUBLE"), ("AGRUPMIN", "DOUBLE"), ("LOTECOMPMINIMO", "DOUBLE"), ("CODPARCCONSIG", "INTEGER"),
               ("AD_CODPRODANTIGO", "VARCHAR")],
    "TGFGRU": [("CODGRUPOPROD", "INTEGER"), ("DESCRGRUPOPROD", "VARCHAR")],
    "TGFVOA": [("CODPROD", "INTEGER"), ("CODVOL", "VARCHAR"), ("DIVIDEMULTIPLICA", "VARCHAR"), ("QUANTIDADE", "DOUBLE"),
               ("ATIVO", "VARCHAR")],
    "TGFEST": [("CODEMP", "INTEGER"), ("CODPROD", "INTEGER"), ("CODLOCAL", "INTEGER"), ("ESTOQUE", "DOUBLE"),
               ("RESERVADO", "DOUBLE"), ("WMSBLOQUEADO", "DOUBLE")],
    "TGFTOP": [("CODTIPOPER", "INTEGER"), ("DHALTER", "TIMESTAMP"), ("DESCROPER", "VARCHAR")],
    "TGFPAR": [("CODPARC", "INTEGER"), ("NOMEPARC", "VARCHAR")],
    "TGFVAR": [("NUNOTA", "BIGINT"), ("NUNOTAORIG", "BIGINT"), ("SEQUENCIAORIG", "INTEGER")],
    "TSILIB": [("TABELA", "VARCHAR"), ("NUCHAVE", "BIGINT"), ("DHLIB", "TIMESTAMP"), ("REPROVADO", "VARCHAR")],
    "BI_PARAM_COMPRA": [("CHAVE", "VARCHAR"), ("VALOR", "VARCHAR")],
    "BI_F_SUGESTAO_COMPRA": [("CODEMP", "INTEGER"), ("CODPROD", "INTEGER"), ("DATA_SNAPSHOT", "TIMESTAMP"),
                             ("QTD_SUGERIDA", "DOUBLE")],
}
OPCIONAIS = {"BI_PARAM_COMPRA", "BI_F_SUGESTAO_COMPRA"}

MACROS = [
    "CREATE MACRO NVL(a, b) AS COALESCE(a, b)",
    "CREATE MACRO TO_NUMBER(a) AS CAST(a AS DOUBLE)",
    "CREATE MACRO TO_DATE(s, f) AS CAST(s AS DATE)",
    "CREATE MACRO ADD_MONTHS(d, n) AS CAST(CAST(d AS DATE) + to_months(CAST(n AS INTEGER)) AS DATE)",
    "CREATE MACRO ORA_TRUNC(d) AS CAST(date_trunc('day', CAST(d AS TIMESTAMP)) AS DATE)",
    "CREATE MACRO ORA_TRUNC_MM(d) AS CAST(date_trunc('month', CAST(d AS TIMESTAMP)) AS DATE)",
    "CREATE MACRO ORA_TO_CHAR(d, f) AS CASE f "
    "WHEN 'YYYY-MM-DD' THEN strftime(CAST(d AS TIMESTAMP), '%Y-%m-%d') "
    "WHEN 'YYYY-MM' THEN strftime(CAST(d AS TIMESTAMP), '%Y-%m') "
    "WHEN 'DD/MM/YYYY' THEN strftime(CAST(d AS TIMESTAMP), '%d/%m/%Y') "
    "WHEN 'DD/MM/YYYY HH24:MI' THEN strftime(CAST(d AS TIMESTAMP), '%d/%m/%Y %H:%M') "
    "ELSE error('formato TO_CHAR nao suportado pelo shim: ' || f) END",
]


class ErroOracleSimulado(Exception):
    """Erro com texto no formato ORA-xxxxx, para o front-end classificar como faria com o Oracle."""


def _literal(valor, tipo):
    s = str(valor)
    if tipo == "I":
        if not re.fullmatch(r"-?\d+", s):
            raise ErroOracleSimulado("ORA-01722: invalid number")
        return s
    return "'" + s.replace("'", "''") + "'"


def preparar(sql, params, sysdate):
    """params: lista de {'value':..., 'type': 'I'|'S'} na ordem dos '?'."""
    partes = sql.split("?")
    if len(partes) - 1 != len(params):
        raise ErroOracleSimulado("ORA-01008: not all variables bound (%d binds, %d valores)" % (len(partes) - 1, len(params)))
    out = partes[0]
    for p, resto in zip(params, partes[1:]):
        out += _literal(p["value"], p["type"]) + resto
    for m in re.finditer(r"TRUNC\(([^()]*(?:\([^()]*\))?[^()]*),\s*'(\w+)'\)", out):
        if m.group(2) != "MM":
            raise AssertionError("TRUNC com formato não suportado pelo shim: " + m.group(2))
    out = re.sub(r"\bTRUNC\(([^()]*(?:\([^()]*\))?[^()]*),\s*'MM'\)", r"ORA_TRUNC_MM(\1)", out)
    out = re.sub(r"\bTRUNC\(", "ORA_TRUNC(", out)
    out = re.sub(r"\bTO_CHAR\(", "ORA_TO_CHAR(", out)
    out = re.sub(r"\bSYSDATE\b", "TIMESTAMP '%s'" % sysdate, out)
    return out


def criar_banco(fixture):
    con = duckdb.connect()
    for m in MACROS:
        con.execute(m)
    con.execute("CREATE TABLE DUAL (DUMMY VARCHAR)")
    con.execute("INSERT INTO DUAL VALUES ('X')")
    tabelas = fixture.get("tabelas", {})
    for nome, colunas in ESQUEMA.items():
        if nome in OPCIONAIS and nome not in tabelas:
            continue
        con.execute("CREATE TABLE %s (%s)" % (nome, ", ".join("%s %s" % c for c in colunas)))
        linhas = tabelas.get(nome, [])
        nomes = [c[0] for c in colunas]
        for linha in linhas:
            desconhecidas = set(linha) - set(nomes)
            if desconhecidas:
                raise AssertionError("Fixture usa coluna fora do esquema em %s: %s" % (nome, desconhecidas))
            con.execute("INSERT INTO %s VALUES (%s)" % (nome, ", ".join("?" for _ in nomes)),
                        [linha.get(n) for n in nomes])
    return con


def executar(con, sql, params, sysdate):
    texto = preparar(sql, params, sysdate)
    try:
        cur = con.execute(texto)
    except duckdb.CatalogException as e:
        if "Table with name" in str(e) and "does not exist" in str(e):
            raise ErroOracleSimulado("ORA-00942: table or view does not exist") from e
        raise
    cols = [d[0] for d in cur.description]
    linhas = []
    for r in cur.fetchall():
        linha = {}
        for c, v in zip(cols, r):
            if hasattr(v, "isoformat"):
                v = v.isoformat()
            elif v is not None and not isinstance(v, (int, float, str)):
                v = float(v)
            linha[c] = v
        linhas.append(linha)
    return linhas


def carregar_fixture(caminho):
    with open(caminho, encoding="utf-8") as f:
        return json.load(f)
