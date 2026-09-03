package br.devlocal.relatorio;

import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.*;

import java.io.FileOutputStream;
import java.time.LocalDate;

/*
 * Gera um arquivo "vendas.xlsx" DE EXEMPLO com dados ficticios do mes atual.
 * Use para demonstrar o sistema para o cliente sem precisar dos dados reais dele.
 *
 * Como rodar:
 *   mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo
 */
public class GerarPlanilhaExemplo {

    public static void main(String[] args) throws Exception {
        String[] produtos = {"Cerveja Lata 350ml", "Refrigerante 2L", "Agua Mineral 500ml",
                             "Carvao 3kg", "Gelo 5kg", "Salginho Congelado 1kg"};
        String[] categorias = {"Bebidas", "Bebidas", "Bebidas", "Churrasco", "Churrasco", "Congelados"};
        double[] precos = {3.49, 8.90, 2.50, 14.90, 6.00, 22.90};

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

            // ~80 vendas ficticias do mes atual
            int linha = 1;
            for (int i = 0; i < 80; i++) {
                int idx = (int) (Math.random() * produtos.length);
                LocalDate data = LocalDate.now().withDayOfMonth(1 + (int) (Math.random() * LocalDate.now().lengthOfMonth()));
                int qtd = 1 + (int) (Math.random() * 20);

                Row r = sheet.createRow(linha++);
                r.createCell(0).setCellValue(data.toString()); // AAAA-MM-DD
                r.createCell(1).setCellValue(produtos[idx]);
                r.createCell(2).setCellValue(categorias[idx]);
                r.createCell(3).setCellValue(qtd);
                r.createCell(4).setCellValue(precos[idx]);
            }

            // Ajusta largura das colunas
            for (int i = 0; i < cabecalho.length; i++) sheet.autoSizeColumn(i);

            try (FileOutputStream out = new FileOutputStream("vendas.xlsx")) {
                wb.write(out);
            }
        }
        System.out.println("OK! Arquivo 'vendas.xlsx' de exemplo gerado na pasta atual.");
        System.out.println("Agora rode: mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp");
    }
}
