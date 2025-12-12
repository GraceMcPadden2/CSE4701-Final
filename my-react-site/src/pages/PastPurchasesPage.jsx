import React, { useEffect, useState } from 'react';

const PastPurchasesPage = ({ customerId: customerIdProp }) => {
  const [purchases, setPurchases] = useState([]);
  const [loading, setLoading] = useState(false);

  const customerId =
    customerIdProp || Number(localStorage.getItem('customerId')) || null;

  useEffect(() => {
    if (!customerId) return;

    setLoading(true);

    fetch(`http://127.0.0.1:5000/purchases/${customerId}`)
      .then((res) => res.json())
      .then((data) => setPurchases(data || []))
      .finally(() => setLoading(false));
  }, [customerId]);

  // Group purchases by transaction_id
  const transactions = Object.values(
    purchases.reduce((acc, p) => {
      acc[p.transaction_id] ||= {
        transaction_id: p.transaction_id,
        transaction_date: p.transaction_date,
        total_amount: p.total_amount,
        items: [],
      };
      acc[p.transaction_id].items.push(p);
      return acc;
    }, {})
  );

  return (
    <div>
      <h1>Past Purchases</h1>

      {loading && <p>Loading...</p>}

      {!loading && transactions.length > 0 && (
        <>
          {transactions.map((t) => (
            <div
              key={t.transaction_id}
              style={{
                border: '1px solid #ccc',
                padding: '1rem',
                marginBottom: '1rem',
              }}
            >
              <p>
                Date:{' '}
                {t.transaction_date
                  ? new Date(t.transaction_date).toLocaleString()
                  : 'N/A'}
              </p>

              <p>Total: ${t.total_amount?.toFixed(2)}</p>

              <ul>
                {t.items.map((item) => (
                  <li key={item.product_id}>
                    {item.product_name} × {item.quantity} — $
                    {item.subtotal?.toFixed(2)}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </>
      )}
    </div>
  );
};

export default PastPurchasesPage;

