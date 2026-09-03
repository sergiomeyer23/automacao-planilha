package br.devlocal.relatorio;

import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/*
 * AUTOMACAO DE PLANILHA DE VENDAS
 * --------------------------------
 * Le o arquivo "vendas.xlsx" e gera automaticamente o "relatorio_vendas.xlsx"
 * com 3 abas: Resumo do mes | Vendas por Produto | Top 5 Produtos.
 *
 * Formato esperado da planilha de entrada (linha 1 = cabecalho):
 *   Data | Produto | Categoria | Quantidade | Preco Unitario (R$)
 * (Data aceita AAAA-MM-DD ou DD/MM/AAAA; preco aceita numero puro ou "R$ 1.234,56")
 *
 * Como rodar:
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp
 */
public class RelatorioVendasApp {

    private static final DateTimeFormatter SAIDA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public static void main(String[] args) throws Exception {
        String entrada = args.length > 0 ? args[0] : "vendas.xlsx";

        List<Venda> vendas = lerPlanilha(entrada);
        if (vendas.isEmpty()) {
            System.out.println("Nenhuma venda encontrada em " + entrada);
            return;
        }

        // ---------- Consolidacao ----------
        BigDecimal totalGeral = BigDecimal.ZERO;
        int totalItens = 0;
        Map<String, BigDecimal> receitaPorProduto = new LinkedHashMap<>();
        Map<String, Integer> qtdPorProduto = new LinkedHashMap<>();
        Map<String, BigDecimal> receitaPorCategoria = new LinkedHashMap<>();

        for (Venda v : vendas) {
            BigDecimal receita = v.precoUnitario.multiply(BigDecimal.valueOf(v.quantidade));
            totalGeral = totalGeral.add(receita);
            totalItens += v.quantidade;
            receitaPorProduto.merge(v.produto, receita, BigDecimal::add);
            qtdPorProduto.merge(v.produto, v.quantidade, Integer::sum);
            receitaPorCategoria.merge(v.categoria, receita, BigDecimal::add);
        }

        BigDecimal ticketMedio = totalGeral.divide(BigDecimal.valueOf(vendas.size()), 2, RoundingMode.HALF_UP);

        // Top 5 produtos por receita
        List<Map.Entry<String, BigDecimal>> top5 = new ArrayList<>(receitaPorProduto.entrySet());
        top5.sort(Map.Entry.<String, BigDecimal>comparingByValue().reversed());
        if (top5.size() > 5) top5 = top5.subList(0, 5);

        // ---------- Gera o Excel de saida ----------
        try (Workbook wb = new XSSFWorkbook()) {
            CellStyle negrito = wb.createCellStyle();
            Font fonte = wb.createFont();
            fonte.setBold(true);
            negrito.setFont(fonte);

            // Aba 1: Resumo
            Sheet resumo = wb.createSheet("Resumo do Mes");
            resumo.createFreezePane(0, 1);
            escreverLinha(resumo, 0, negrito, "RELATORIO DE VENDAS - " + LocalDate.now().format(SAIDA));
            escreverLinha(resumo, 2, negrito, "Indicador", "Valor");
            escreverLinha(resumo, 3, "Faturamento total (R$)", totalGeral);
            escreverLinha(resumo, 4, "Numero de vendas", vendas.size());
            escreverLinha(resumo, 5, "Itens vendidos", totalItens);
            escreverLinha(resumo, 6, "Ticket medio por venda (R$)", ticketMedio);
            escreverLinha(resumo, 8, negrito, "Faturamento por Categoria");
            escreverLinha(resumo, 9, negrito, "Categoria", "Receita (R$)", "% do total");
            int l = 10;
            for (Map.Entry<String, BigDecimal> e : receitaPorCategoria.entrySet()) {
                BigDecimal pct = e.getValue().multiply(BigDecimal.valueOf(100))
                        .divide(totalGeral, 1, RoundingMode.HALF_UP);
                escreverLinha(resumo, l++, e.getKey(), e.getValue(), pct + "%");
            }

            // Aba 2: Por produto
            Sheet porProduto = wb.createSheet("Vendas por Produto");
            escreverLinha(porProduto, 0, negrito, "Produto", "Qtd Vendida", "Receita (R$)", "% do Total");
            int lp = 1;
            for (String p : receitaPorProduto.keySet()) {
                BigDecimal pct = receitaPorProduto.get(p).multiply(BigDecimal.valueOf(100))
                        .divide(totalGeral, 1, RoundingMode.HALF_UP);
                escreverLinha(porProduto, lp++, p, qtdPorProduto.get(p), receitaPorProduto.get(p), pct + "%");
            }
            for (int i = 0; i < 4; i++) porProduto.autoSizeColumn(i);

            // Aba 3: Top 5
            Sheet top = wb.createSheet("Top 5 Produtos");
            escreverLinha(top, 0, negrito, "Posicao", "Produto", "Receita (R$)");
            int lt = 1, pos = 1;
            for (Map.Entry<String, BigDecimal> e : top5) {
                escreverLinha(top, lt++, pos++ + "o", e.getKey(), e.getValue());
            }
            for (int i = 0; i < 3; i++) top.autoSizeColumn(i);

            String saida = "relatorio_vendas.xlsx";
            try (FileOutputStream out = new FileOutputStream(saida)) {
                wb.write(out);
            }
            System.out.println("=================================================");
            System.out.println(" RELATORIO GERADO: " + saida);
            System.out.println("=================================================");
            System.out.printf("Faturamento total : R$ %,.2f%n", totalGeral);
            System.out.printf("Numero de vendas  : %d%n", vendas.size());
            System.out.printf("Ticket medio      : R$ %,.2f%n", ticketMedio);
            System.out.printf("Produto campeao   : %s (R$ %,.2f)%n", top5.get(0).getKey(), top5.get(0).getValue());
        }
    }

    // ================= Modelo e leitura =================

    static class Venda {
        LocalDate data;
        String produto;
        String categoria;
        int quantidade;
        BigDecimal precoUnitario;
    }

    private static List<Venda> lerPlanilha(String caminho) throws Exception {
        List<Venda> vendas = new ArrayList<>();
        try (Workbook wb = WorkbookFactory.create(new FileInputStream(caminho))) {
            Sheet sheet = wb.getSheetAt(0);
            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // pula cabecalho
                Row r = sheet.getRow(i);
                if (r == null) continue;

                Venda v = new Venda();
                v.data = lerData(celulaTexto(r.getCell(0)));
                v.produto = celulaTexto(r.getCell(1)).trim();
                v.categoria = celulaTexto(r.getCell(2)).trim();
                if (v.produto.isEmpty()) continue;

                Cell cQtd = r.getCell(3);
                v.quantidade = (cQtd != null && cQtd.getCellType() == CellType.NUMERIC)
                        ? (int) cQtd.getNumericCellValue() : parseInteiro(celulaTexto(cQtd));

                v.precoUnitario = lerValor(r.getCell(4));
                vendas.add(v);
            }
        }
        return vendas;
    }

    private static String celulaTexto(Cell c) {
        if (c == null) return "";
        if (c.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c))
            return c.getLocalDateTimeCellValue().toLocalDate().toString();
        switch (c.getCellType()) {
            case NUMERIC: return String.valueOf(c.getNumericCellValue());
            case STRING:  return c.getStringCellValue();
            case FORMULA:
                try { return c.getStringCellValue(); } catch (Exception e) { return String.valueOf(c.getNumericCellValue()); }
            default: return "";
        }
    }

    private static LocalDate lerData(String t) {
        if (t == null || t.isEmpty()) return LocalDate.now();
        t = t.trim();
        try { return LocalDate.parse(t); } catch (Exception ignored) {}
        try { return LocalDate.parse(t, DateTimeFormatter.ofPattern("dd/MM/yyyy")); } catch (Exception ignored) {}
        return LocalDate.now();
    }

    private static BigDecimal lerValor(Cell c) {
        if (c == null) return BigDecimal.ZERO;
        if (c.getCellType() == CellType.NUMERIC) return BigDecimal.valueOf(c.getNumericCellValue()).setScale(2, RoundingMode.HALF_UP);
        String t = celulaTexto(c).replace("R$", "").replace(" ", "")
                .replace(".", "").replace(",", ".");
        try { return new BigDecimal(t).setScale(2, RoundingMode.HALF_UP); }
        catch (Exception e) { return BigDecimal.ZERO; }
    }

    private static int parseInteiro(String t) {
        try { return Integer.parseInt(t.trim().replaceAll("\\..*", "")); }
        catch (Exception e) { return 0; }
    }

    // ================= Helpers de escrita =================

    private static void escreverLinha(Sheet s, int n, Object... valores) { escreverLinha(s, n, null, valores); }

    private static void escreverLinha(Sheet s, int n, CellStyle estilo, Object... valores) {
        Row r = s.createRow(n);
        for (int i = 0; i < valores.length; i++) {
            Cell c = r.createCell(i);
            Object v = valores[i];
            if (v instanceof Number) c.setCellValue(((Number) v).doubleValue());
            else c.setCellValue(String.valueOf(v));
            if (estilo != null) c.setCellStyle(estilo);
        }
    }
}
