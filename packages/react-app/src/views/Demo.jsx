import React from "react";
import M3Button from "../components/M3Button";

const Demo = () => {
  return (
    <div style={{ width: "100%" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: "1rem", margin: "2rem" }}>
        <div style={{ display: "flex", gap: "1rem" }}>
          <M3Button variant="filled">Filled button</M3Button>
          <M3Button variant="filled" icon={<span className="material-icons">info</span>}>
            Filled button
          </M3Button>
          <M3Button variant="filled" disabled>
            Disabled
          </M3Button>
        </div>
        <div style={{ display: "flex", gap: "1rem" }}>
          <M3Button variant="outline">Outline button</M3Button>
          <M3Button variant="outline" icon={<span className="material-icons">delete</span>}>
            Outline button
          </M3Button>
          <M3Button variant="outline" disabled>
            Disabled
          </M3Button>
        </div>
        <div style={{ display: "flex", gap: "1rem" }}>
          <M3Button variant="text">Text button</M3Button>
          <M3Button variant="text" icon={<span className="material-icons">add</span>}>
            Text button
          </M3Button>
          <M3Button variant="text" disabled>
            Disabled
          </M3Button>
        </div>
        <div style={{ display: "flex", gap: "1rem" }}>
          <M3Button variant="elevated">Elevated button</M3Button>
          <M3Button variant="elevated" icon={<span className="material-icons">thumb_up</span>}>
            Elevated button
          </M3Button>
          <M3Button variant="elevated" disabled>
            Disabled
          </M3Button>
        </div>
        <div style={{ display: "flex", gap: "1rem" }}>
          <M3Button variant="tonal">Tonal button</M3Button>
          <M3Button variant="tonal" icon={<span className="material-icons">autorenew</span>}>
            Tonal button
          </M3Button>
          <M3Button variant="tonal" disabled>
            Disabled
          </M3Button>
        </div>
      </div>
    </div>
  );
};

export default Demo;
