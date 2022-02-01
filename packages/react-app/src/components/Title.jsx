import M3Typography from "../M3Typography";

const Title = ({ children }) => (
  <M3Typography fontTokenId="md.sys.typescale.title-large" style={{ textAlign: "center", maxWidth: "42rem" }}>
    {children}
  </M3Typography>
);

export default Title;
