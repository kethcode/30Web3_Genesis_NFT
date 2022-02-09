import React, { useEffect, useState } from "react";
import { useThemeSwitcher } from "react-css-theme-switcher";
import M3Button from "./M3Button";

export default function ThemeSwitcher() {
  const [theme, setTheme] = useState(window.localStorage.getItem("theme") ?? "dark");
  const { switcher } = useThemeSwitcher();

  useEffect(() => {
    window.localStorage.setItem("theme", theme);
  }, [theme]);

  const toggleTheme = () => {
    const newTheme = theme === "dark" ? "light" : "dark";
    setTheme(newTheme);
    switcher({ theme: newTheme });
  };

  return (
    <M3Button
      variant="text"
      onlyIcon
      onClick={toggleTheme}
      icon={
        theme === "dark" ? (
          <span className="material-icons">dark_mode</span>
        ) : (
          <span className="material-icons">light_mode</span>
        )
      }
    />
  );
}
