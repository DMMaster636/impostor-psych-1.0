package shaders;

class HeatwaveShader
{
    public var shader(default, null):FabsShaderGLSL = new FabsShaderGLSL();
	public var distortTexture(default, set):Array<String> = ['polus/heatwave', 'impostor'];

    public function new(?_image:String = 'polus/heatwave', ?_folder:String = 'impostor'):Void
    {
        distortTexture = [_image, _folder];
        shader.distortTexture.input = Paths.bitmap(_image, _folder);
    }

    function set_distortTexture(v:Array<String>):Array<String>
    {
		distortTexture = v;
		shader.distortTexture.input = Paths.bitmap(distortTexture[0], distortTexture[1]);
		return v;
	}

    /*
    // gotta move this to an update function later
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        shader.iTime.value = [elapsed];
    }
    */
}

class FabsShaderGLSL extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform sampler2D distortTexture;
        uniform float iTime;

        void main() {
            vec2 p_m = openfl_TextureCoordv;
            vec2 p_d = p_m;

            p_d.t -= iTime * 0.05;
            p_d.t = mod(p_d.t, 1.0);

            vec4 dst_map_val = flixel_texture2D(distortTexture, p_d);

            vec2 dst_offset = dst_map_val.xy;
            dst_offset -= vec2(.5,.5);
            dst_offset *= 2.;
            dst_offset *= 0.009; //THIS CONTROLS THE INTENSITY [higher numbers = MORE WAVY]

            //reduce effect towards Y top
            dst_offset *= pow(p_m.t, 1.4); //THIS CONTROLS HOW HIGH UP THE SCREEN THE EFFECT GOES [higher numbers = less screen space]

            vec2 dist_tex_coord = p_m.st + dst_offset;
            gl_FragColor = flixel_texture2D(bitmap, dist_tex_coord); 
        }')

    public function new()
    {
        super();
    }
}