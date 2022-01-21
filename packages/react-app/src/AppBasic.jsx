import React from "react";
import { Route, Switch } from "react-router-dom";
import { ThemeProvider } from "styled-components";
import theme from "./themes/theme";
import ButtonsDemo from "./views/ButtonsDemo";
import Connect from "./views/Connect";

const AppBasic = () => {
  return (
    <ThemeProvider theme={theme}>
      <Switch>
        <Route exact path="/">
          <Connect />
        </Route>
        <Route exact path="/buttons">
          <ButtonsDemo />
        </Route>
      </Switch>
    </ThemeProvider>
  );
};

export default AppBasic;
