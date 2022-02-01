import M3Typography from "../M3Typography";

const Subtitle = ({ children }) => (
  <M3Typography
    fontTokenId="md.sys.typescale.body-large"
    colorTokenId="md.sys.color.on-surface-variant"
    style={{ textAlign: "center", maxWidth: "42rem" }}
  >
    {children}
  </M3Typography>
);

export default Subtitle;
