import React from "react";
import { BrowserRouter, Route, Switch } from "react-router-dom";

/**
 * This router is convenient for development.
 * It exposes the "true" app under the route "/",
 * while conserving the app bootstraped by scaffold-eth
 * and exposing it under "/scaffold-eth"
 * All <Link> will properly include the right subroute.
 */
const DualRouter = ({ app, scaffoldEthApp }) => (
  <BrowserRouter>
    <Switch>
      <Route path="/scaffold-eth">
        <BrowserRouter basename="scaffold-eth">{scaffoldEthApp}</BrowserRouter>
      </Route>
      <Route path="/">
        <BrowserRouter basename="app">{app}</BrowserRouter>
      </Route>
    </Switch>
  </BrowserRouter>
);

export default DualRouter;
