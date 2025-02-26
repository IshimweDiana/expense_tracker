import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFService {
  static Future<File> generateExpenseReport(
    List<Map<String, dynamic>> expenses,
    Map<String, double> categoryTotals,
  ) async {
    final pdf = pw.Document();
    final double totalExpenses = expenses.fold(
      0.0,
      (sum, expense) => sum + (expense['amount'] as double),
    );

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Expense Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Total Expenses Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Text(
                  'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),
              _buildCategoryTable(categoryTotals),
              pw.SizedBox(height: 20),
              _buildExpenseTable(expenses),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/expense_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildCategoryTable(Map<String, double> categoryTotals) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.TableHelper.fromTextArray(
        headers: ['Category', 'Total Amount'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        data:
            categoryTotals.entries
                .map((e) => [e.key, '\$${e.value.toStringAsFixed(2)}'])
                .toList(),
        cellAlignment: pw.Alignment.center,
        cellStyle: const pw.TextStyle(fontSize: 12),
      ),
    );
  }

  static pw.Widget _buildExpenseTable(List<Map<String, dynamic>> expenses) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.TableHelper.fromTextArray(
        headers: ['Date', 'Category', 'Amount', 'Description'],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        data:
            expenses
                .map(
                  (e) => [
                    e['date'],
                    e['category'],
                    '\$${e['amount'].toStringAsFixed(2)}',
                    e['description'],
                  ],
                )
                .toList(),
        cellAlignment: pw.Alignment.center,
        cellStyle: const pw.TextStyle(fontSize: 12),
      ),
    );
  }
}
