#if TOOLS
using Godot;
using System;

[Tool]
public partial class GodoTeX : EditorPlugin {
	public override void _EnterTree() {
		var texture_grey = GD.Load<Texture2D>("addons/godotex/iconGrey.svg");
		var texture_script = GD.Load<Script>("addons/godotex/LaTeXture.cs");
		AddCustomType("LaTeXture", "ImageTexture", texture_script, texture_grey);
		
		var texture_red = GD.Load<Texture2D>("addons/godotex/iconRed.svg");
		var spatial_script = GD.Load<Script>("addons/godotex/LaTeX3D.cs");
		AddCustomType("LaTeX3D", "Sprite3D", spatial_script, texture_red);
		
		var texture = GD.Load<Texture2D>("addons/godotex/icon.svg");
		var script = GD.Load<Script>("addons/godotex/LaTeX2D.cs");
		AddCustomType("LaTeX2D", "Sprite2D", script, texture);
		
		var texture_button = GD.Load<Texture2D>("addons/godotex/iconButton.svg");
		var button_script = GD.Load<Script>("addons/godotex/LaTeXButton.cs");
		AddCustomType("LaTeXButton", "TextureButton", button_script, texture_button);
	}

	public override void _ExitTree() {
		RemoveCustomType("LaTeX2D");
		RemoveCustomType("LaTeX3D");
		RemoveCustomType("LaTeXture");
		RemoveCustomType("LaTeXButton");
	}
}
#endif
