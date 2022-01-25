import React from "react";
import M3Button from "./M3Button";

// added display of 0 instead of NaN if gas price is not provided

/*
  ~ What it does? ~

  Displays gas gauge

  ~ How can I use? ~

  <GasGauge
    gasPrice={gasPrice}
  />

  ~ Features ~

  - Provide gasPrice={gasPrice} and get current gas gauge
*/

export default function GasGauge(props) {
  return (
    <M3Button
      variant="text"
      icon={<span className="material-icons">local_gas_station</span>}
      onClick={() => {
        window.open("https://ethgasstation.info/");
      }}
    >
      {typeof props.gasPrice === "undefined" ? 0 : parseInt(props.gasPrice, 10) / 10 ** 9}g
    </M3Button>
  );
}
