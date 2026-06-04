import React from 'react';
export const DataTable: React.FC<{ columns: any[]; data: any[] }> = ({ columns, data }) => {
  return (
    <table className="min-w-full">
      <thead>
        <tr>{columns.map(col => <th key={col.key}>{col.title}</th>)}
      </thead>
      <tbody>
        {data.map((row, i) => (
          <tr key={i}>
            {columns.map(col => <td key={col.key}>{row[col.key]}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  );
};
