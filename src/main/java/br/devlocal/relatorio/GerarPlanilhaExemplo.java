package br.devlocal.relatorio;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Random;

/*
 * Gera um arquivo "vendas.xlsx" DE EXEMPLO com 80 vendas ficticias do mes atual.
 * Use para demonstrar o sistema sem precisar dos dados reais do cliente.
 *
 * Como rodar:
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo -Dexec.args="exemplos/vendas.xlsx"
 */
public class GerarPlanilhaExemplo {

    private static final DateTimeFormatter BR = DateTimeFormatter.ofPattern("dd/MM/uuuu");

    public static void main(String[] args) throws Exception {
        Path saida = Paths.get(args.length > 0 ? args[0] : "vendas.xlsx");
        Path pai = saida.toAbsolutePath().getParent();
        if (pai != null) Files.createDirectories(pai);

        String[] produtos = {"Cerveja Lata 350ml", "Refrigerante 2L", "Agua Mineral 500ml",
                             "Carvao 3kg", "Gelo 5kg", "Salginho Congelado 1kg"};
        String[] categorias = {"Bebidas", "Bebidas", "Bebidas", "Churrasco", "Churrasco", "Congelados"};
        double[] precos = {3.49, 8.90, 2.50, 14.90, 6.00, 22.90};

        Random random = new Random(42);
        LocalDate hoje = LocalDate.now();

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Vendas");

            // Cabecalho
            String[] cabecalho = {"Data", "Produto", "Categoria", "Quantidade", "Preco Unitario (R$)"};
            Row header = sheet.createRow(0);
            CellStyle estiloHeader = wb.createCellStyle();
            Font fonte = wb.createFont();
            fonte.setBold(true);
            estiloHeader.setFont(fonte);
            for (int i = 0; i < cabecalho.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(cabecalho[i]);
                c.setCellStyle(estiloHeader);
            }

            // 80 vendas ficticias do mes atual, alternando os dois formatos de data aceitos
            int linha = 1;
            for (int i = 0; i < 80; i++) {
                int idx = random.nextInt(produtos.length);
                LocalDate data = hoje.withDayOfMonth(1 + random.nextInt(hoje.lengthOfMonth()));
                int qtd = 1 + random.nextInt(20);

                Row r = sheet.createRow(linha++);
                r.createCell(0).setCellValue(i % 2 == 0 ? data.toString() : data.format(BR));
                r.createCell(1).setCellValue(produtos[idx]);
                r.createCell(2).setCellValue(categorias[idx]);
                r.createCell(3).setCellValue(qtd);
                r.createCell(4).setCellValue(precos[idx]);
            }

            // Ajusta largura das colunas
            for (int i = 0; i < cabecalho.length; i++) sheet.autoSizeColumn(i);

            try (OutputStream out = Files.newOutputStream(saida)) {
                wb.write(out);
            }
        }

        System.out.println("OK! Arquivo de exemplo gerado: " + saida.toAbsolutePath());
        System.out.println("Agora rode: mvn -q compile exec:java "
                + "-Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp");
    }
}
