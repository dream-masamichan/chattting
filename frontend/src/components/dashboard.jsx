import React, { useEffect, useState } from "react";

const Dashboard = () => {
  const [message, setMessage] = useState("");

  useEffect(() => {
    fetch("http://localhost:3000/api/v1/dashboard/index")  // ✅ Rails API からデータ取得
      .then((response) => response.json())
      .then((data) => setMessage(data.message))
      .catch((error) => console.error("API Error:", error));
  }, []);

  return (
    <div>
      <h1>Dashboard</h1>
      <p>{message}</p>
    </div>
  );
};

export default Dashboard;
