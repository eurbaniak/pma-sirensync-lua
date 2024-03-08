import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

interface ReturnData {
  x: number;
  y: number;
  z: number;
}

const App: React.FC = () => {
  const [clientData, setClientData] = useState<ReturnData | null>(null);

  const handleGetClientData = () => {
    fetchNui<ReturnData>("getClientData")
      .then((retData) => {
        console.log("Got return data from client scripts:");
        console.dir(retData);
        setClientData(retData);
      })
      .catch((e) => {
        console.error("Setting mock data due to error", e);
        setClientData({ x: 500, y: 300, z: 200 });
      });
  };

  return (
    <div className="control-wrapper">
      <div className="control"></div>
    </div>
  );
};

export default App;
