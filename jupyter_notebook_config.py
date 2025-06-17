from pathlib import Path

def _set_dark_theme():
    # Path to JupyterLab user settings for theme
    user_settings = Path.home() / ".jupyter" / "lab" / "user-settings" / "@jupyterlab" / "apputils-extension"
    user_settings.mkdir(parents=True, exist_ok=True)
    settings_file = user_settings / "themes.jupyterlab-settings"
    settings_file.write_text('{"theme": "JupyterLab Dark"}')

_set_dark_theme()
