import React, { useEffect, useState } from "react";
import { useThemeSwitcher } from "react-css-theme-switcher";
import M3Button from "./M3Button";

export default function ThemeSwitcher() {
  const [theme, setTheme] = useState(window.localStorage.getItem("theme"));
  const { switcher } = useThemeSwitcher();

  useEffect(() => {
    window.localStorage.setItem("theme", theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : "light");
    switcher({ theme: theme });
  };

  return (
    <M3Button
      variant="text"
      onClick={toggleTheme}
      icon={
        theme === "light" ? (
          <span class="material-icons">light_mode</span>
        ) : (
          <span class="material-icons">dark_mode</span>
        )
      }
    />
  );
}
