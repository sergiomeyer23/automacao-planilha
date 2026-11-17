"""Lê do stdin {"consultas": {...}, "tabelas": {...}, "casos": [{"id","params","sysdate"}]} e
devolve no stdout a lista de resultados [{"ok": true, "linhas": [...]}, {"ok": false, "erro": "..."}].
Executa o SQL GERADO no DuckDB via oracle_shim (simulação; não é Oracle)."""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import oracle_shim as sh  # noqa: E402


def main():
    entrada = json.load(sys.stdin)
    con = sh.criar_banco({"tabelas": entrada["tabelas"]})
    saida = []
    for caso in entrada["casos"]:
        q = entrada["consultas"][caso["id"]]
        try:
            linhas = sh.executar(con, q["sql"], caso["params"], caso["sysdate"])
            saida.append({"ok": True, "linhas": linhas})
        except sh.ErroOracleSimulado as e:
            saida.append({"ok": False, "erro": str(e)})
        except Exception as e:  # erro de SQL real (sintaxe/semântica) também volta como texto
            saida.append({"ok": False, "erro": "SQL: " + str(e)})
    json.dump(saida, sys.stdout)


if __name__ == "__main__":
    main()
