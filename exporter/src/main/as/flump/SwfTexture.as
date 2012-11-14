//
// Flump - Copyright 2012 Three Rings Design

package flump {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import flump.executor.load.LoadedSwf;
import flump.mold.MovieMold;
import flump.xfl.XflLibrary;
import flump.xfl.XflTexture;

public class SwfTexture
{
    public var symbol :String;
    public var offset :Point;
    public var w :int, h :int, a :int;
    public var scale :Number;

    public static function fromFlipbook (lib :XflLibrary, movie :MovieMold, frame :int,
        scale :Number = 1) :SwfTexture {

        const klass :Class = Class(lib.swf.getSymbol(movie.id));
        const clip :MovieClip = MovieClip(new klass());
        clip.gotoAndStop(frame + 1);
        const name :String = movie.id + "_flipbook_" + frame;
        return new SwfTexture(name, clip, scale);
    }

    public static function fromTexture (swf :LoadedSwf, tex :XflTexture,
        scale :Number = 1) :SwfTexture {

        const klass :Class = Class(swf.getSymbol(tex.symbol));
        const instance :Object = new klass();
        const disp :DisplayObject = (instance is BitmapData) ?
            new Bitmap(BitmapData(instance)) : DisplayObject(instance);
        return new SwfTexture(tex.symbol, disp, scale);
    }

    public function SwfTexture (symbol :String, disp :DisplayObject, scale :Number) {
        this.symbol = symbol;
        this.scale = scale;
        _disp = disp;

        offset = getOffset(_disp, scale);

        const size :Point = getSize(_disp, scale);
        w = size.x;
        h = size.y;
        a = w * h;
    }

    public function toBitmapData () :BitmapData {
        return Util.renderToBitmapData(_disp, w, h, scale);
    }

    public function toString () :String { return "a " + a + " w " + w + " h " + h; }

    protected static function getSize (disp :DisplayObject, scale :Number) :Point {
        const bounds :Rectangle = getBounds(disp, scale);
        return new Point(Math.ceil(bounds.width), Math.ceil(bounds.height));
    }

    protected static function getOffset (disp :DisplayObject, scale :Number) :Point {
        const bounds :Rectangle = getBounds(disp, scale);
        return new Point(bounds.x, bounds.y);
    }

    protected static function getBounds (disp :DisplayObject, scale :Number) :Rectangle {
        const oldScale :Number = disp.scaleX;
        disp.scaleX = disp.scaleY = scale;
        const holder :Sprite = new Sprite();
        holder.addChild(disp);
        const bounds :Rectangle = disp.getBounds(holder);
        disp.scaleX = disp.scaleY = oldScale;
        return bounds;
    }

    protected var _disp :DisplayObject;
}
}
