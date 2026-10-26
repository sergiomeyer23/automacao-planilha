package br.devlocal.relatorio;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.YearMonth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RelatorioVendasAppTest {

    @TempDir
    Path tempDir;

    @Test
    void parseValorAceitaFormatosComuns() {
        assertEquals(new BigDecimal("3.49"), RelatorioVendasApp.parseValor("3.49"));
        assertEquals(new BigDecimal("3.49"), RelatorioVendasApp.parseValor("3,49"));
        assertEquals(new BigDecimal("3.49"), RelatorioVendasApp.parseValor("  R$ 3,49  "));
        assertEquals(new BigDecimal("1234.56"), RelatorioVendasApp.parseValor("R$ 1.234,56"));
        assertEquals(new BigDecimal("1234.56"), RelatorioVendasApp.parseValor("1,234.56"));
        assertEquals(new BigDecimal("1234.56"), RelatorioVendasApp.parseValor("1 234,56"));
        assertEquals(new BigDecimal("1234.00"), RelatorioVendasApp.parseValor("1.234"));
        assertEquals(new BigDecimal("1234567.00"), RelatorioVendasApp.parseValor("1.234.567"));
        assertEquals(new BigDecimal("-1234.56"), RelatorioVendasApp.parseValor("(1.234,56)"));

        assertNull(RelatorioVendasApp.parseValor(""));
        assertNull(RelatorioVendasApp.parseValor("abc"));
        assertNull(RelatorioVendasApp.parseValor("R$"));
    }

    @Test
    void parseDataAceitaFormatosERejeitaDataInvalida() {
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("2026-10-01"));
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("01/10/2026"));
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("1/10/2026"));
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("01-10-2026"));
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("2026-10-01T10:30:00"));
        assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.parseData("01/10/2026 10:30"));

        assertNull(RelatorioVendasApp.parseData("31/02/2026"));
        assertNull(RelatorioVendasApp.parseData("2026-13-01"));
        assertNull(RelatorioVendasApp.parseData(""));
    }

    @Test
    void lerDataAceitaCelulaFormatadaERejeitaNumeroSemFormatoDeData() throws IOException {
        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Vendas");
            Row row = sheet.createRow(0);

            Cell dataFormatada = row.createCell(0);
            dataFormatada.setCellValue(LocalDate.of(2026, 10, 1));
            CellStyle estilo = wb.createCellStyle();
            estilo.setDataFormat(wb.createDataFormat().getFormat("dd/MM/yyyy"));
            dataFormatada.setCellStyle(estilo);
            assertEquals(LocalDate.of(2026, 10, 1), RelatorioVendasApp.lerData(dataFormatada));

            Cell serial = row.createCell(1);
            serial.setCellValue(DateUtil.getExcelDate(java.sql.Date.valueOf(LocalDate.of(2026, 10, 1))));
            assertNull(RelatorioVendasApp.lerData(serial));
        }
    }

    @Test
    void lerQuantidadeAceitaInteirosERejeitaFracao() throws IOException {
        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Vendas");
            Cell cell = sheet.createRow(0).createCell(0);

            cell.setCellValue(3.0);
            assertEquals(Integer.valueOf(3), RelatorioVendasApp.lerQuantidade(cell));

            cell.setCellValue(2.5);
            assertNull(RelatorioVendasApp.lerQuantidade(cell));

            cell.setCellValue("4");
            assertEquals(Integer.valueOf(4), RelatorioVendasApp.lerQuantidade(cell));

            cell.setCellValue("4,0");
            assertEquals(Integer.valueOf(4), RelatorioVendasApp.lerQuantidade(cell));

            cell.setCellValue("abc");
            assertNull(RelatorioVendasApp.lerQuantidade(cell));
        }
    }

    @Test
    void lerPlanilhaIgnoraLinhasInvalidasEUsaCategoriaPadrao() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Cerveja", "Bebidas", 2, 3.49},
                {"31/02/2026", "DataInvalida", "Bebidas", 1, 10.0},
                {"2026-10-02", "Salgado", "", 1, "R$ 1.234,56"},
                {"2026-10-03", "QuantidadeZero", "Bebidas", 0, 10.0},
                {"2026-10-04", "PrecoInvalido", "Bebidas", 1, "abc"},
                {"2026-11-01", "Refrigerante", "Bebidas", 3, 10.0}
        });

        RelatorioVendasApp.Leitura leitura = RelatorioVendasApp.lerPlanilha(entrada);

        assertEquals(3, leitura.vendas.size());
        assertEquals(3, leitura.avisos.size());
        assertEquals(YearMonth.of(2026, 11), leitura.ultimoMes());
        assertEquals("2026-10, 2026-11", leitura.mesesDisponiveis());

        RelatorioVendasApp.Venda cerveja = leitura.vendas.stream()
                .filter(v -> v.produto.equals("Cerveja"))
                .findFirst()
                .orElseThrow();
        assertEquals(new BigDecimal("3.49"), cerveja.precoUnitario);

        RelatorioVendasApp.Venda salgado = leitura.vendas.stream()
                .filter(v -> v.produto.equals("Salgado"))
                .findFirst()
                .orElseThrow();
        assertEquals("Sem categoria", salgado.categoria);
        assertEquals(new BigDecimal("1234.56"), salgado.precoUnitario);
    }

    @Test
    void geraRelatorioDoMesMaisRecentePorPadrao() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Cerveja", "Bebidas", 2, 3.49},
                {"2026-10-02", "Salgado", "Congelados", 1, 10.00},
                {"2026-11-01", "Refrigerante", "Bebidas", 3, 10.00}
        });
        Path saida = tempDir.resolve("sub/dir/relatorio.xlsx");

        RelatorioVendasApp.Relatorio relatorio = RelatorioVendasApp.gerarRelatorio(entrada, saida, null);

        assertEquals(YearMonth.of(2026, 11), relatorio.mes);
        assertEquals(1, relatorio.vendas.size());
        assertEquals(new BigDecimal("30.00"), relatorio.totalGeral);
        assertEquals(3, relatorio.totalItens);
        assertEquals(new BigDecimal("30.00"), relatorio.ticketMedio);
        assertTrue(Files.exists(saida));

        assertEquals("11/2026", valorDaCelula(saida, "Resumo do Mes", "Mes de referencia"));
        assertEquals("30.0", valorDaCelula(saida, "Resumo do Mes", "Faturamento total (R$)"));
        assertEquals("3.0", valorDaCelula(saida, "Vendas por Produto", "TOTAL", 1));
        assertEquals("30.0", valorDaCelula(saida, "Vendas por Produto", "TOTAL", 2));
        assertEquals("100,0%", valorDaCelula(saida, "Vendas por Produto", "TOTAL", 3));
        assertEquals("Refrigerante", valorDaCelula(saida, "Top 5 Produtos", "1o", 1));
        assertEquals("30.0", valorDaCelula(saida, "Top 5 Produtos", "1o", 2));
    }

    @Test
    void geraRelatorioDeMesEspecifico() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Cerveja", "Bebidas", 2, 3.49},
                {"2026-10-02", "Salgado", "Congelados", 1, 10.00},
                {"2026-11-01", "Refrigerante", "Bebidas", 3, 10.00}
        });
        Path saida = tempDir.resolve("relatorio-outubro.xlsx");

        RelatorioVendasApp.Relatorio relatorio = RelatorioVendasApp.gerarRelatorio(
                entrada, saida, YearMonth.of(2026, 10));

        assertEquals(YearMonth.of(2026, 10), relatorio.mes);
        assertEquals(2, relatorio.vendas.size());
        assertEquals(3, relatorio.totalItens);
        assertEquals(new BigDecimal("16.98"), relatorio.totalGeral);
        assertEquals(new BigDecimal("8.49"), relatorio.ticketMedio);
        assertEquals("Salgado", relatorio.top5.get(0).getKey());
        assertEquals("Congelados", relatorio.receitaPorCategoria.keySet().iterator().next());
    }

    @Test
    void totalZeroNaoQuebraPercentuais() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Brinde", "Promocao", 2, 0.00}
        });
        Path saida = tempDir.resolve("relatorio-zero.xlsx");

        RelatorioVendasApp.Relatorio relatorio = RelatorioVendasApp.gerarRelatorio(entrada, saida, null);

        assertEquals(new BigDecimal("0.00"), relatorio.totalGeral);
        assertEquals(new BigDecimal("0.00"), relatorio.ticketMedio);
        assertEquals("0,0%", RelatorioVendasApp.formatarPercentual(BigDecimal.ZERO, BigDecimal.ZERO));
        assertEquals("0,0%", valorDaCelula(saida, "Resumo do Mes", "Promocao", 2));
        assertEquals("0,0%", valorDaCelula(saida, "Vendas por Produto", "TOTAL", 3));
    }

    @Test
    void falhaComMensagemQuandoMesNaoTemVendas() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Cerveja", "Bebidas", 1, 10.00}
        });

        IllegalArgumentException erro = assertThrows(IllegalArgumentException.class,
                () -> RelatorioVendasApp.gerarRelatorio(
                        entrada, tempDir.resolve("relatorio.xlsx"), YearMonth.of(2026, 12)));

        assertTrue(erro.getMessage().contains("2026-12"));
        assertTrue(erro.getMessage().contains("2026-10"));
    }

    @Test
    void falhaQuandoArquivoDeEntradaNaoExiste() {
        Path entrada = tempDir.resolve("nao-existe.xlsx");

        IllegalArgumentException erro = assertThrows(IllegalArgumentException.class,
                () -> RelatorioVendasApp.gerarRelatorio(
                        entrada, tempDir.resolve("relatorio.xlsx"), null));

        assertTrue(erro.getMessage().contains("nao encontrado"));
    }

    @Test
    void falhaQuandoSaidaIgualEntrada() throws IOException {
        Path entrada = criarPlanilha(new Object[][]{
                {"2026-10-01", "Cerveja", "Bebidas", 1, 10.00}
        });

        IllegalArgumentException erro = assertThrows(IllegalArgumentException.class,
                () -> RelatorioVendasApp.gerarRelatorio(entrada, entrada, null));

        assertTrue(erro.getMessage().contains("diferente"));
    }

    @Test
    void parseArgsAceitaPosicionaisEOpcoes() {
        RelatorioVendasApp.Config posicional = RelatorioVendasApp.Config.parse(
                new String[]{"entrada.xlsx", "saida.xlsx", "10/2026"});
        assertEquals(Paths.get("entrada.xlsx"), posicional.entrada);
        assertEquals(Paths.get("saida.xlsx"), posicional.saida);
        assertEquals(YearMonth.of(2026, 10), posicional.mes);

        RelatorioVendasApp.Config opcoes = RelatorioVendasApp.Config.parse(
                new String[]{"--entrada=in.xlsx", "--saida=out.xlsx", "--mes=2026-10"});
        assertEquals(Paths.get("in.xlsx"), opcoes.entrada);
        assertEquals(Paths.get("out.xlsx"), opcoes.saida);
        assertEquals(YearMonth.of(2026, 10), opcoes.mes);
    }

    @Test
    void parseArgsRejeitaMesInvalido() {
        assertThrows(IllegalArgumentException.class,
                () -> RelatorioVendasApp.Config.parse(new String[]{"--mes=outubro"}));
        assertThrows(IllegalArgumentException.class,
                () -> RelatorioVendasApp.Config.parse(new String[]{"--mes=2026-13"}));
    }

    // ================= Helpers =================

    private Path criarPlanilha(Object[][] linhas) throws IOException {
        Path arquivo = tempDir.resolve("vendas-" + System.nanoTime() + ".xlsx");
        try (Workbook wb = new XSSFWorkbook();
             OutputStream out = Files.newOutputStream(arquivo)) {

            Sheet sheet = wb.createSheet("Vendas");
            Row cabecalho = sheet.createRow(0);
            String[] nomes = {"Data", "Produto", "Categoria", "Quantidade", "Preco Unitario (R$)"};
            for (int i = 0; i < nomes.length; i++) {
                cabecalho.createCell(i).setCellValue(nomes[i]);
            }

            for (int i = 0; i < linhas.length; i++) {
                Row row = sheet.createRow(i + 1);
                for (int j = 0; j < linhas[i].length; j++) {
                    Object valor = linhas[i][j];
                    if (valor == null) continue;
                    if (valor instanceof Number) {
                        row.createCell(j).setCellValue(((Number) valor).doubleValue());
                    } else {
                        row.createCell(j).setCellValue(String.valueOf(valor));
                    }
                }
            }

            wb.write(out);
        }
        return arquivo;
    }

    private String valorDaCelula(Path arquivo, String aba, String rotulo) throws IOException {
        return valorDaCelula(arquivo, aba, rotulo, 1);
    }

    private String valorDaCelula(Path arquivo, String aba, String rotulo, int coluna) throws IOException {
        try (InputStream in = Files.newInputStream(arquivo);
             Workbook wb = WorkbookFactory.create(in)) {

            Sheet sheet = wb.getSheet(aba);
            assertNotNull(sheet, "Aba nao encontrada: " + aba);

            for (Row row : sheet) {
                Cell primeira = row.getCell(0);
                if (primeira == null || primeira.getCellType() != CellType.STRING) continue;
                if (!rotulo.equals(primeira.getStringCellValue())) continue;

                Cell celula = row.getCell(coluna);
                if (celula == null) return null;
                if (celula.getCellType() == CellType.NUMERIC) {
                    return String.valueOf(celula.getNumericCellValue());
                }
                if (celula.getCellType() == CellType.STRING) {
                    return celula.getStringCellValue();
                }
                return null;
            }
        }
        return null;
    }
}
