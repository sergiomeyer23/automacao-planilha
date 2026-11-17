"""Validação ESTÁTICA do SQL gerado com sqlglot, dialeto Oracle:
  1. parse: sintaxe reconhecida pelo parser Oracle do sqlglot;
  2. qualify: toda coluna referenciada existe no esquema DEMONSTRADO (oracle_shim.ESQUEMA) ou num CTE,
     sem referência a alias do mesmo SELECT e sem GROUP BY por alias (regras do Oracle que o DuckDB não cobra).
NÃO prova que o Oracle/Sankhya aceita a consulta (versão, permissões, colunas reais, desempenho).
Uso: python validar_sqlglot.py sql/gerado/consultas.json -> JSON {id: {"parse": "...", "colunas": "..."}}"""
import json
import os
import sys

import sqlglot
from sqlglot.errors import ParseError
from sqlglot.optimizer.qualify import qualify

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import oracle_shim as sh  # noqa: E402

TIPO = {"BIGINT": "DECIMAL", "INTEGER": "DECIMAL", "DOUBLE": "DECIMAL", "VARCHAR": "VARCHAR", "TIMESTAMP": "DATE"}
ESQUEMA = {t: {c: TIPO[ty] for c, ty in cols} for t, cols in sh.ESQUEMA.items()}
ESQUEMA["DUAL"] = {"DUMMY": "VARCHAR"}

dados = json.load(open(sys.argv[1], encoding="utf-8"))
saida = {}
for id_, q in sorted(dados["consultas"].items()):
    r = {}
    texto = q["sql"].replace("?", ":b")
    try:
        arvores = sqlglot.parse(texto, read="oracle", error_level=sqlglot.ErrorLevel.RAISE)
        r["parse"] = "ok" if len(arvores) == 1 else "erro: %d comandos" % len(arvores)
    except ParseError as e:
        r["parse"] = "erro: " + str(e).split("\n")[0][:300]
    try:
        qualify(sqlglot.parse_one(texto, read="oracle"), schema=ESQUEMA, dialect="oracle", validate_qualify_columns=True)
        r["colunas"] = "ok"
    except Exception as e:  # noqa: BLE001
        r["colunas"] = "erro: " + str(e).split("\n")[0][:300]
    saida[id_] = r
print(json.dumps(saida, ensure_ascii=False))
