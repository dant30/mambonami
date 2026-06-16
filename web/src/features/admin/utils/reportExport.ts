import { jsPDF } from 'jspdf';

type Row = Record<string, unknown>;

export const downloadCsv = (filename: string, rows: Row[], headers?: string[]) => {
  const columns =
    headers ||
    Array.from(
      rows.reduce((set, row) => {
        Object.keys(row).forEach((key) => set.add(key));
        return set;
      }, new Set<string>()),
    );

  const csvContent = [
    columns.join(','),
    ...rows.map((row) =>
      columns
        .map((column) => {
          const value = row[column];
          const cell = value === null || value === undefined ? '' : String(value);
          const escaped = cell.replace(/"/g, '""');
          return `"${escaped}"`;
        })
        .join(','),
    ),
  ].join('\r\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
};

export const downloadPdf = (filename: string, title: string, rows: Row[], columns: string[]) => {
  const doc = new jsPDF({ unit: 'pt', format: 'letter' });
  const margin = 40;
  const lineHeight = 18;
  const pageWidth = doc.internal.pageSize.getWidth();
  const usableWidth = pageWidth - margin * 2;
  const columnWidth = usableWidth / columns.length;
  let y = margin;

  doc.setFontSize(16);
  doc.text(title, margin, y);
  y += lineHeight * 1.5;
  doc.setFontSize(10);

  const drawRow = (values: string[]) => {
    values.forEach((value, index) => {
      const x = margin + index * columnWidth;
      doc.text(String(value).slice(0, 35), x, y, {
        maxWidth: columnWidth - 10,
      });
    });
    y += lineHeight;
    if (y > doc.internal.pageSize.getHeight() - margin) {
      doc.addPage();
      y = margin;
    }
  };

  drawRow(columns);
  rows.forEach((row) => {
    const values = columns.map((column) => {
      const value = row[column];
      return value === null || value === undefined ? '' : String(value);
    });
    drawRow(values);
  });

  doc.save(filename);
};
