package br.devlocal.relatorio;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/*
 * AUTOMACAO DE PLANILHA DE VENDAS
 * --------------------------------
 * Le uma planilha de vendas e gera um relatorio Excel com 3 abas:
 * Resumo do Mes | Vendas por Produto | Top 5 Produtos.
 *
 * Formato esperado da planilha de entrada (linha 1 = cabecalho):
 *   Data | Produto | Categoria | Quantidade | Preco Unitario (R$)
 *
 * A data pode ser uma celula formatada como data, AAAA-MM-DD ou DD/MM/AAAA.
 * O preco aceita numero puro (3.49), formato brasileiro (R$ 1.234,56) ou
 * formato americano (1,234.56).
 *
 * Por padrao o relatorio usa o mes mais recente encontrado na planilha.
 * Tambem e possivel informar o mes desejado (AAAA-MM ou MM/AAAA).
 *
 * Como rodar:
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp -Dexec.args="vendas.xlsx relatorio.xlsx 2026-10"
 */
public class RelatorioVendasApp {

    private static final DateTimeFormatter SAIDA = DateTimeFormatter.ofPattern("dd/MM/uuuu");
    private static final DateTimeFormatter MES_SAIDA = DateTimeFormatter.ofPattern("MM/uuuu");
    private static final DateTimeFormatter MES_ENTRADA = DateTimeFormatter.ofPattern("M/uuuu")
            .withResolverStyle(ResolverStyle.STRICT);

    private static final DateTimeFormatter[] FORMATOS_DATA = {
            DateTimeFormatter.ISO_LOCAL_DATE,
            DateTimeFormatter.ofPattern("d/M/uuuu").withResolverStyle(ResolverStyle.STRICT),
            DateTimeFormatter.ofPattern("d-M-uuuu").withResolverStyle(ResolverStyle.STRICT)
    };

    private static final int LIMITE_AVISOS = 20;

    public static void main(String[] args) {
        try {
            Config config = Config.parse(args);
            if (config.ajuda) {
                imprimirUso();
                return;
            }

            Relatorio relatorio = gerarRelatorio(config.entrada, config.saida, config.mes);
            int limite = Math.min(relatorio.avisos.size(), LIMITE_AVISOS);
            for (int i = 0; i < limite; i++) {
                System.err.println("Aviso: " + relatorio.avisos.get(i));
            }
            if (relatorio.avisos.size() > limite) {
                System.err.println("Aviso: mais " + (relatorio.avisos.size() - limite)
                        + " linha(s) invalida(s) foram ignoradas.");
            }
            imprimirResumo(relatorio);
        } catch (IllegalArgumentException e) {
            System.err.println("Erro: " + e.getMessage());
            System.err.println();
            imprimirUso();
            System.exit(1);
        } catch (Exception e) {
            System.err.println("Erro ao gerar o relatorio: " + e.getMessage());
            System.exit(1);
        }
    }

    // ================= CLI =================

    static final class Config {
        final Path entrada;
        final Path saida;
        final YearMonth mes;
        final boolean ajuda;

        Config(Path entrada, Path saida, YearMonth mes, boolean ajuda) {
            this.entrada = entrada;
            this.saida = saida;
            this.mes = mes;
            this.ajuda = ajuda;
        }

        static Config parse(String[] args) {
            Path entrada = Paths.get("vendas.xlsx");
            Path saida = Paths.get("relatorio_vendas.xlsx");
            YearMonth mes = null;
            boolean ajuda = false;
            int posicionais = 0;

            for (String arg : args) {
                if (arg == null || arg.trim().isEmpty()) continue;
                String a = arg.trim();

                if (a.equals("-h") || a.equals("--ajuda") || a.equals("--help")) {
                    ajuda = true;
                    continue;
                }
                if (a.startsWith("--entrada=")) {
                    entrada = Paths.get(valorOpcao(a));
                    continue;
                }
                if (a.startsWith("--saida=")) {
                    saida = Paths.get(valorOpcao(a));
                    continue;
                }
                if (a.startsWith("--mes=")) {
                    mes = parseMes(valorOpcao(a));
                    continue;
                }
                if (a.startsWith("-")) {
                    throw new IllegalArgumentException("Opcao desconhecida: " + a);
                }

                switch (posicionais) {
                    case 0:
                        entrada = Paths.get(a);
                        break;
                    case 1:
                        saida = Paths.get(a);
                        break;
                    case 2:
                        mes = parseMes(a);
                        break;
                    default:
                        throw new IllegalArgumentException("Argumento extra: " + a);
                }
                posicionais++;
            }

            return new Config(entrada, saida, mes, ajuda);
        }

        private static String valorOpcao(String arg) {
            int separador = arg.indexOf('=');
            String valor = separador >= 0 ? arg.substring(separador + 1).trim() : "";
            if (valor.isEmpty()) {
                throw new IllegalArgumentException("Valor ausente em: " + arg);
            }
            return valor;
        }
    }

    private static void imprimirUso() {
        System.out.println("Uso: RelatorioVendasApp [entrada.xlsx] [saida.xlsx] [AAAA-MM]");
        System.out.println();
        System.out.println("Opcoes:");
        System.out.println("  --entrada=ARQUIVO  Planilha de vendas (padrao: vendas.xlsx)");
        System.out.println("  --saida=ARQUIVO    Relatorio gerado (padrao: relatorio_vendas.xlsx)");
        System.out.println("  --mes=AAAA-MM      Mes de referencia (padrao: mes mais recente da planilha)");
        System.out.println("  -h, --ajuda        Exibe esta ajuda");
        System.out.println();
        System.out.println("Exemplos:");
        System.out.println("  mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp");
        System.out.println("  mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp "
                + "-Dexec.args=\"vendas.xlsx relatorio.xlsx 2026-10\"");
    }

    // ================= Fluxo principal =================

    static Relatorio gerarRelatorio(Path entrada, Path saida, YearMonth mesFiltro) throws IOException {
        if (entrada == null || saida == null) {
            throw new IllegalArgumentException("Os caminhos de entrada e de saida sao obrigatorios.");
        }
        if (!Files.exists(entrada)) {
            throw new IllegalArgumentException("Arquivo de entrada nao encontrado: " + entrada.toAbsolutePath());
        }
        if (Files.isDirectory(entrada)) {
            throw new IllegalArgumentException("O caminho de entrada e um diretorio: " + entrada.toAbsolutePath());
        }
        if (Files.exists(saida) && Files.isSameFile(entrada, saida)) {
            throw new IllegalArgumentException("O arquivo de saida deve ser diferente do arquivo de entrada.");
        }

        Leitura leitura = lerPlanilha(entrada);
        if (leitura.vendas.isEmpty()) {
            String sufixo = leitura.avisos.isEmpty() ? "" : " Linhas ignoradas: " + leitura.avisos.size() + ".";
            throw new IllegalArgumentException("Nenhuma venda valida encontrada em "
                    + entrada.getFileName() + "." + sufixo);
        }

        YearMonth referencia = mesFiltro != null ? mesFiltro : leitura.ultimoMes();
        List<Venda> filtradas = leitura.vendas.stream()
                .filter(v -> YearMonth.from(v.data).equals(referencia))
                .collect(Collectors.toList());

        if (filtradas.isEmpty()) {
            throw new IllegalArgumentException("Nao ha vendas em " + referencia
                    + ". Meses disponiveis: " + leitura.mesesDisponiveis() + ".");
        }

        Relatorio relatorio = new Relatorio(filtradas, referencia, entrada, saida, leitura.avisos);
        escreverRelatorio(relatorio);
        return relatorio;
    }

    // ================= Modelo e leitura =================

    static final class Venda {
        final LocalDate data;
        final String produto;
        final String categoria;
        final int quantidade;
        final BigDecimal precoUnitario;

        Venda(LocalDate data, String produto, String categoria, int quantidade, BigDecimal precoUnitario) {
            this.data = data;
            this.produto = produto;
            this.categoria = categoria;
            this.quantidade = quantidade;
            this.precoUnitario = precoUnitario;
        }
    }

    static final class Leitura {
        final List<Venda> vendas;
        final List<String> avisos;

        Leitura(List<Venda> vendas, List<String> avisos) {
            this.vendas = Collections.unmodifiableList(new ArrayList<>(vendas));
            this.avisos = Collections.unmodifiableList(new ArrayList<>(avisos));
        }

        YearMonth ultimoMes() {
            return vendas.stream()
                    .map(v -> YearMonth.from(v.data))
                    .max(Comparator.naturalOrder())
                    .orElse(null);
        }

        String mesesDisponiveis() {
            return vendas.stream()
                    .map(v -> YearMonth.from(v.data))
                    .distinct()
                    .sorted()
                    .map(YearMonth::toString)
                    .collect(Collectors.joining(", "));
        }
    }

    static Leitura lerPlanilha(Path caminho) throws IOException {
        List<Venda> vendas = new ArrayList<>();
        List<String> avisos = new ArrayList<>();

        try (InputStream in = Files.newInputStream(caminho);
             Workbook wb = WorkbookFactory.create(in)) {

            Sheet sheet = wb.getSheetAt(0);
            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // linha 0 = cabecalho
                Row r = sheet.getRow(i);
                if (r == null || linhaVazia(r)) continue;

                int numeroLinha = i + 1;
                LocalDate data = lerData(r.getCell(0));
                if (data == null) {
                    avisos.add("Linha " + numeroLinha + ": data invalida ou ausente; linha ignorada.");
                    continue;
                }

                String produto = celulaTexto(r.getCell(1)).trim();
                if (produto.isEmpty()) {
                    avisos.add("Linha " + numeroLinha + ": produto vazio; linha ignorada.");
                    continue;
                }

                String categoria = celulaTexto(r.getCell(2)).trim();
                if (categoria.isEmpty()) categoria = "Sem categoria";

                Integer quantidade = lerQuantidade(r.getCell(3));
                if (quantidade == null || quantidade <= 0) {
                    avisos.add("Linha " + numeroLinha + ": quantidade invalida ("
                            + celulaTexto(r.getCell(3)) + "); linha ignorada.");
                    continue;
                }

                BigDecimal preco = lerValor(r.getCell(4));
                if (preco == null || preco.signum() < 0) {
                    avisos.add("Linha " + numeroLinha + ": preco invalido ("
                            + celulaTexto(r.getCell(4)) + "); linha ignorada.");
                    continue;
                }

                vendas.add(new Venda(data, produto, categoria, quantidade, preco));
            }
        }

        return new Leitura(vendas, avisos);
    }

    private static boolean linhaVazia(Row r) {
        for (int i = 0; i < 5; i++) {
            if (!celulaTexto(r.getCell(i)).trim().isEmpty()) return false;
        }
        return true;
    }

    static String celulaTexto(Cell c) {
        if (c == null) return "";

        if (c.getCellType() == CellType.NUMERIC) {
            if (DateUtil.isCellDateFormatted(c)) {
                return c.getLocalDateTimeCellValue().toLocalDate().toString();
            }
            return BigDecimal.valueOf(c.getNumericCellValue()).stripTrailingZeros().toPlainString();
        }

        if (c.getCellType() == CellType.FORMULA) {
            CellType tipo = c.getCachedFormulaResultType();
            if (tipo == CellType.NUMERIC) {
                if (DateUtil.isCellDateFormatted(c)) {
                    return c.getLocalDateTimeCellValue().toLocalDate().toString();
                }
                return BigDecimal.valueOf(c.getNumericCellValue()).stripTrailingZeros().toPlainString();
            }
            if (tipo == CellType.STRING) return c.getStringCellValue();
            if (tipo == CellType.BOOLEAN) return String.valueOf(c.getBooleanCellValue());
            return "";
        }

        if (c.getCellType() == CellType.STRING) return c.getStringCellValue();
        if (c.getCellType() == CellType.BOOLEAN) return String.valueOf(c.getBooleanCellValue());
        return "";
    }

    static LocalDate lerData(Cell c) {
        if (c == null) return null;

        // Numeros so sao tratados como data quando a celula tem formato de data.
        // Assim, um "2026" digitado por engano na coluna de data nao vira 1905.
        if (c.getCellType() == CellType.NUMERIC) {
            if (!DateUtil.isCellDateFormatted(c)) return null;
            try {
                return c.getLocalDateTimeCellValue().toLocalDate();
            } catch (RuntimeException e) {
                return null;
            }
        }

        if (c.getCellType() == CellType.FORMULA && c.getCachedFormulaResultType() == CellType.NUMERIC) {
            if (!DateUtil.isCellDateFormatted(c)) return null;
            try {
                return c.getLocalDateTimeCellValue().toLocalDate();
            } catch (RuntimeException e) {
                return null;
            }
        }

        return parseData(celulaTexto(c));
    }

    static LocalDate parseData(String texto) {
        if (texto == null) return null;
        String t = texto.trim();
        if (t.isEmpty()) return null;

        int espaco = t.indexOf(' ');
        if (espaco > 0) t = t.substring(0, espaco);
        int tSep = t.indexOf('T');
        if (tSep > 0) t = t.substring(0, tSep);

        for (DateTimeFormatter formato : FORMATOS_DATA) {
            try {
                return LocalDate.parse(t, formato);
            } catch (DateTimeParseException ignored) {
                // tenta o proximo formato
            }
        }
        return null;
    }

    static BigDecimal lerValor(Cell c) {
        if (c == null) return null;
        if (c.getCellType() == CellType.NUMERIC) {
            return BigDecimal.valueOf(c.getNumericCellValue()).setScale(2, RoundingMode.HALF_UP);
        }
        if (c.getCellType() == CellType.FORMULA && c.getCachedFormulaResultType() == CellType.NUMERIC) {
            return BigDecimal.valueOf(c.getNumericCellValue()).setScale(2, RoundingMode.HALF_UP);
        }
        return parseValor(celulaTexto(c));
    }

    static BigDecimal parseValor(String texto) {
        if (texto == null) return null;
        String t = texto.replace('\u00A0', ' ').trim();
        if (t.isEmpty()) return null;

        boolean negativo = t.startsWith("(") && t.endsWith(")");
        if (negativo) t = t.substring(1, t.length() - 1);

        t = t.replaceAll("\\s+", "");
        t = t.replaceAll("(?i)R\\$", "");
        if (t.isEmpty()) return null;
        if (t.startsWith("+")) t = t.substring(1);
        if (!t.matches("[+-]?[0-9.,]+")) return null;

        int ultimaVirgula = t.lastIndexOf(',');
        int ultimoPonto = t.lastIndexOf('.');

        if (ultimaVirgula >= 0 && ultimoPonto >= 0) {
            if (ultimaVirgula > ultimoPonto) {
                t = t.replace(".", "").replace(',', '.');
            } else {
                t = t.replace(",", "");
            }
        } else if (ultimaVirgula >= 0) {
            int virgulas = contar(t, ',');
            t = virgulas > 1 ? t.replace(",", "") : t.replace(',', '.');
        } else if (ultimoPonto >= 0) {
            int pontos = contar(t, '.');
            if (pontos > 1) {
                t = t.replace(".", "");
            } else {
                int digitosDepois = t.length() - ultimoPonto - 1;
                boolean pareceMilhar = digitosDepois == 3
                        && ultimoPonto > 0
                        && ultimoPonto <= 3
                        && !t.startsWith("0");
                if (pareceMilhar) t = t.replace(".", "");
            }
        }

        try {
            BigDecimal valor = new BigDecimal(t);
            if (negativo) valor = valor.negate();
            return valor.setScale(2, RoundingMode.HALF_UP);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    static Integer lerQuantidade(Cell c) {
        if (c == null) return null;

        if (c.getCellType() == CellType.NUMERIC) {
            return quantidadeNumerica(c.getNumericCellValue());
        }
        if (c.getCellType() == CellType.FORMULA && c.getCachedFormulaResultType() == CellType.NUMERIC) {
            return quantidadeNumerica(c.getNumericCellValue());
        }

        BigDecimal valor = parseValor(celulaTexto(c));
        if (valor == null) return null;
        try {
            return valor.intValueExact();
        } catch (ArithmeticException e) {
            return null;
        }
    }

    private static Integer quantidadeNumerica(double valor) {
        if (!Double.isFinite(valor) || valor != Math.rint(valor)
                || valor < Integer.MIN_VALUE || valor > Integer.MAX_VALUE) {
            return null;
        }
        return (int) valor;
    }

    static YearMonth parseMes(String texto) {
        if (texto == null || texto.trim().isEmpty()) {
            throw new IllegalArgumentException("Mes vazio.");
        }
        String t = texto.trim();
        try {
            return YearMonth.parse(t);
        } catch (DateTimeParseException ignored) {
            // tenta MM/AAAA
        }
        try {
            return YearMonth.parse(t, MES_ENTRADA);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Mes invalido: '" + texto + "'. Use AAAA-MM ou MM/AAAA.");
        }
    }

    private static int contar(String texto, char caractere) {
        int total = 0;
        for (int i = 0; i < texto.length(); i++) {
            if (texto.charAt(i) == caractere) total++;
        }
        return total;
    }

    // ================= Consolidacao =================

    static final class Relatorio {
        final YearMonth mes;
        final Path entrada;
        final Path saida;
        final List<Venda> vendas;
        final BigDecimal totalGeral;
        final long totalItens;
        final BigDecimal ticketMedio;
        final Map<String, BigDecimal> receitaPorProduto;
        final Map<String, Long> qtdPorProduto;
        final Map<String, BigDecimal> receitaPorCategoria;
        final List<Map.Entry<String, BigDecimal>> top5;
        final List<String> avisos;

        Relatorio(List<Venda> vendas, YearMonth mes, Path entrada, Path saida, List<String> avisos) {
            this.mes = mes;
            this.entrada = entrada;
            this.saida = saida;
            this.vendas = Collections.unmodifiableList(new ArrayList<>(vendas));
            this.avisos = Collections.unmodifiableList(new ArrayList<>(avisos));

            BigDecimal total = BigDecimal.ZERO;
            long itens = 0;
            Map<String, BigDecimal> receitaProduto = new LinkedHashMap<>();
            Map<String, Long> qtdProduto = new LinkedHashMap<>();
            Map<String, BigDecimal> receitaCategoria = new LinkedHashMap<>();

            for (Venda v : vendas) {
                BigDecimal receita = v.precoUnitario.multiply(BigDecimal.valueOf(v.quantidade));
                total = total.add(receita);
                itens += v.quantidade;
                receitaProduto.merge(v.produto, receita, BigDecimal::add);
                qtdProduto.merge(v.produto, (long) v.quantidade, Long::sum);
                receitaCategoria.merge(v.categoria, receita, BigDecimal::add);
            }

            this.totalGeral = total;
            this.totalItens = itens;
            this.ticketMedio = vendas.isEmpty()
                    ? BigDecimal.ZERO.setScale(2)
                    : total.divide(BigDecimal.valueOf(vendas.size()), 2, RoundingMode.HALF_UP);
            this.receitaPorProduto = ordenarPorValor(receitaProduto);
            this.qtdPorProduto = Collections.unmodifiableMap(new LinkedHashMap<>(qtdProduto));
            this.receitaPorCategoria = ordenarPorValor(receitaCategoria);
            this.top5 = Collections.unmodifiableList(new ArrayList<>(this.receitaPorProduto.entrySet())
                    .subList(0, Math.min(5, this.receitaPorProduto.size())));
        }
    }

    private static Map<String, BigDecimal> ordenarPorValor(Map<String, BigDecimal> valores) {
        Comparator<Map.Entry<String, BigDecimal>> comparador =
                Map.Entry.<String, BigDecimal>comparingByValue().reversed()
                        .thenComparing(Map.Entry.comparingByKey());
        Map<String, BigDecimal> ordenado = valores.entrySet().stream()
                .sorted(comparador)
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (a, b) -> a,
                        LinkedHashMap::new));
        return Collections.unmodifiableMap(ordenado);
    }

    static String formatarPercentual(BigDecimal valor, BigDecimal total) {
        if (valor == null || total == null || total.signum() == 0) return "0,0%";
        BigDecimal percentual = valor.multiply(BigDecimal.valueOf(100))
                .divide(total, 1, RoundingMode.HALF_UP);
        return percentual.toPlainString().replace('.', ',') + "%";
    }

    // ================= Geracao do Excel =================

    private static void escreverRelatorio(Relatorio r) throws IOException {
        Path pai = r.saida.toAbsolutePath().getParent();
        if (pai != null) Files.createDirectories(pai);

        try (Workbook wb = new XSSFWorkbook()) {
            CellStyle negrito = wb.createCellStyle();
            Font fonte = wb.createFont();
            fonte.setBold(true);
            negrito.setFont(fonte);

            // Aba 1: Resumo
            Sheet resumo = wb.createSheet("Resumo do Mes");
            resumo.createFreezePane(0, 1);
            escreverLinha(resumo, 0, negrito, "RELATORIO DE VENDAS - " + r.mes.format(MES_SAIDA));
            escreverLinha(resumo, 1, "Periodo: " + r.mes.atDay(1).format(SAIDA)
                    + " a " + r.mes.atEndOfMonth().format(SAIDA));
            escreverLinha(resumo, 3, negrito, "Indicador", "Valor");
            escreverLinha(resumo, 4, "Mes de referencia", r.mes.format(MES_SAIDA));
            escreverLinha(resumo, 5, "Arquivo de origem", r.entrada.getFileName().toString());
            escreverLinha(resumo, 6, "Faturamento total (R$)", r.totalGeral);
            escreverLinha(resumo, 7, "Numero de vendas", r.vendas.size());
            escreverLinha(resumo, 8, "Itens vendidos", r.totalItens);
            escreverLinha(resumo, 9, "Ticket medio por venda (R$)", r.ticketMedio);
            escreverLinha(resumo, 10, "Linhas ignoradas", r.avisos.size());
            escreverLinha(resumo, 12, negrito, "Faturamento por Categoria");
            escreverLinha(resumo, 13, negrito, "Categoria", "Receita (R$)", "% do total");
            int linha = 14;
            for (Map.Entry<String, BigDecimal> e : r.receitaPorCategoria.entrySet()) {
                escreverLinha(resumo, linha++, e.getKey(), e.getValue(),
                        formatarPercentual(e.getValue(), r.totalGeral));
            }
            resumo.setColumnWidth(0, 34 * 256);
            resumo.setColumnWidth(1, 18 * 256);
            resumo.setColumnWidth(2, 12 * 256);

            // Aba 2: Por produto
            Sheet porProduto = wb.createSheet("Vendas por Produto");
            escreverLinha(porProduto, 0, negrito, "Produto", "Qtd Vendida", "Receita (R$)", "% do Total");
            int lp = 1;
            for (Map.Entry<String, BigDecimal> e : r.receitaPorProduto.entrySet()) {
                escreverLinha(porProduto, lp++, e.getKey(), r.qtdPorProduto.get(e.getKey()), e.getValue(),
                        formatarPercentual(e.getValue(), r.totalGeral));
            }
            escreverLinha(porProduto, lp, negrito, "TOTAL", r.totalItens, r.totalGeral,
                    formatarPercentual(r.totalGeral, r.totalGeral));
            for (int i = 0; i < 4; i++) porProduto.autoSizeColumn(i);

            // Aba 3: Top 5
            Sheet top = wb.createSheet("Top 5 Produtos");
            escreverLinha(top, 0, negrito, "Posicao", "Produto", "Receita (R$)");
            int lt = 1;
            int pos = 1;
            for (Map.Entry<String, BigDecimal> e : r.top5) {
                escreverLinha(top, lt++, pos++ + "o", e.getKey(), e.getValue());
            }
            for (int i = 0; i < 3; i++) top.autoSizeColumn(i);

            try (OutputStream out = Files.newOutputStream(r.saida)) {
                wb.write(out);
            }
        }
    }

    private static void escreverLinha(Sheet s, int n, Object... valores) {
        escreverLinha(s, n, null, valores);
    }

    private static void escreverLinha(Sheet s, int n, CellStyle estilo, Object... valores) {
        Row r = s.createRow(n);
        for (int i = 0; i < valores.length; i++) {
            Cell c = r.createCell(i);
            Object v = valores[i];
            if (v == null) {
                c.setCellValue("");
            } else if (v instanceof Number) {
                c.setCellValue(((Number) v).doubleValue());
            } else {
                c.setCellValue(String.valueOf(v));
            }
            if (estilo != null) c.setCellStyle(estilo);
        }
    }

    private static void imprimirResumo(Relatorio r) {
        Locale ptBr = Locale.forLanguageTag("pt-BR");
        System.out.println("=================================================");
        System.out.println(" RELATORIO GERADO: " + r.saida);
        System.out.println(" Mes de referencia: " + r.mes.format(MES_SAIDA));
        System.out.println("=================================================");
        System.out.printf(ptBr, "Faturamento total : R$ %,.2f%n", r.totalGeral);
        System.out.printf(ptBr, "Numero de vendas  : %d%n", r.vendas.size());
        System.out.printf(ptBr, "Itens vendidos    : %d%n", r.totalItens);
        System.out.printf(ptBr, "Ticket medio      : R$ %,.2f%n", r.ticketMedio);
        if (!r.top5.isEmpty()) {
            System.out.printf(ptBr, "Produto campeao   : %s (R$ %,.2f)%n",
                    r.top5.get(0).getKey(), r.top5.get(0).getValue());
        }
        if (!r.avisos.isEmpty()) {
            System.out.printf(ptBr, "Linhas ignoradas  : %d%n", r.avisos.size());
        }
    }
}
