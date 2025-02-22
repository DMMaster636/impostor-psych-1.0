package shaders;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
#end

import shaders.ErrorHandledShader;

class ShaderHelper
{
	public static var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public static function createRuntimeShader(name:String, ?forceShader:Bool = false):ErrorHandledRuntimeShader
	{
		if(!ClientPrefs.data.shaders && !forceShader) return new ErrorHandledRuntimeShader();

		#if (!flash && sys)
		if(!runtimeShaders.exists(name) && !initRuntimeShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new ErrorHandledRuntimeShader(name);
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new ErrorHandledRuntimeShader(name, arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public static function initRuntimeShader(name:String, ?forceShader:Bool = false, ?modsAllowed:Bool = true)
	{
		if(!ClientPrefs.data.shaders && !forceShader) return false;

		#if (!flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/');
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			foldersToCheck.insert(0, Paths.mods('shaders/'));

			if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
				foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

			for(mod in Mods.getGlobalMods())
				foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		}
		#end

		for (folder in foldersToCheck)
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				return true;
			}
		}
		#if SCRIPTS_ALLOWED
		if(PlayState.instance != null)
			PlayState.instance.addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		else #end
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}

	public static function getShader(obj:FlxSprite):Dynamic
	{
		if(obj == null)
		{
			FlxG.log.warn('Error on getting shader: Object $obj not found');
			return null;
		}
		#if (!flash && sys)
		return cast (obj.shader, FlxRuntimeShader);
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		return null;
		#end
	}
}