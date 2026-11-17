"""Servidor local de TESTE: simula o que o Construtor de BI faria com o JSP (remove diretivas JSP,
resolve as 3 expressões EL) e expõe um executeQuery falso que roda o SQL GERADO no DuckDB (oracle_shim).
NÃO é o Sankhya: serve para testar a integração da página com o contrato executeQuery(sql, params, ok, erro).

Uso: python servidor.py <porta> <fixture.json> [sysdate]
  /painel.html            -> página sem executeQuery (deve bloquear) ou ?modo=demo
  /painel_real.html       -> página com executeQuery simulado (resposta no envelope visto no Construtor)
"""
import json
import os
import random
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, "..", "sql"))
import oracle_shim as sh  # noqa: E402

RAIZ = os.path.abspath(os.path.join(AQUI, "..", ".."))
PORTA = int(sys.argv[1])
FIXTURE = json.load(open(sys.argv[2], encoding="utf-8"))
SYSDATE = sys.argv[3] if len(sys.argv) > 3 else "2026-11-17 10:30:00"
TRAVA = threading.Lock()
CON = sh.criar_banco({"tabelas": FIXTURE["tabelas"]})
PERIODO = FIXTURE.get("periodo", {"INI": "", "FIN": "", "CODEMP": ""})

STUB = """<script>
window.__consultas = [];
window.executeQuery = function (sql, params, ok, erro) {
  window.__consultas.push({ params: params });
  var x = new XMLHttpRequest();
  x.open("POST", "/q", true);
  x.onload = function () {
    if (x.status === 200) {
      /* Envelope observado no Construtor: objeto cujo toString devolve o JSON */
      var txt = x.responseText;
      ok({ c: { b: txt }, b: null, toString: function () { return txt; } });
    } else { erro(x.responseText); }
  };
  x.onerror = function () { erro("falha de rede no servidor de teste"); };
  x.send(JSON.stringify({ sql: sql, params: params }));
};
</script>
"""


def pagina(real):
    jsp = open(os.path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"), encoding="utf-8").read()
    linhas = [l for l in jsp.split("\n") if not l.startswith("<%@")]
    html = "\n".join(linhas).replace("<snk:load/>", "")
    html = html.replace("${PERIODO.INI}", PERIODO.get("INI", "")).replace("${PERIODO.FIN}", PERIODO.get("FIN", "")) \
               .replace("${CODEMP}", PERIODO.get("CODEMP", ""))
    if real:
        html = html.replace("</head>", STUB + "</head>", 1)
    return html


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _resp(self, cod, corpo, tipo="text/html; charset=utf-8"):
        dados = corpo.encode("utf-8")
        self.send_response(cod)
        self.send_header("Content-Type", tipo)
        self.send_header("Content-Length", str(len(dados)))
        self.end_headers()
        self.wfile.write(dados)

    def do_GET(self):
        caminho = self.path.split("?")[0]
        if caminho == "/painel.html":
            return self._resp(200, pagina(False))
        if caminho == "/painel_real.html":
            return self._resp(200, pagina(True))
        return self._resp(404, "nao encontrado")

    def do_POST(self):
        n = int(self.headers.get("Content-Length", "0"))
        req = json.loads(self.rfile.read(n))
        time.sleep(random.uniform(0.02, 0.35))  # embaralha a ordem das respostas
        try:
            with TRAVA:
                linhas = sh.executar(CON, req["sql"], req["params"], SYSDATE)
            self._resp(200, json.dumps(linhas), "application/json")
        except Exception as e:
            self._resp(500, str(e), "text/plain; charset=utf-8")


ThreadingHTTPServer(("127.0.0.1", PORTA), H).serve_forever()
