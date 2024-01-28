/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package net.manaten.edg2gif;

import js.node.console.Console;

import haxe.io.Bytes;
import hxpixel.images.edg.EdgDecoder;
import hxpixel.images.file.PixelArtFileType;
import hxpixel.images.gif.GifConverter;
import hxpixel.images.gif.GifEncoder;
import hxpixel.images.utils.FileUtils;

import sys.FileSystem;
import sys.io.File;

class Edg2Gif
{

    static function main()
    {
        new Edg2Gif().run(Sys.args());
    }

    public function new() {

    }

    function run(args: Array<String>)
    {
        if (args.length < 1) {
            printUsage();
            return;
        }

        for (filePath in args) {
            if (!validFile(filePath)) {
                continue;
            }

            var fileBytes = File.getBytes(filePath);
            convert(filePath, fileBytes);
        }
    }


    function printUsage()
    {
        Sys.println("Usage: egd2gif <image-file>...");
        Sys.println("Version 0.0.1");
    }

    function validFile(src:String):Bool
    {
        if (!FileSystem.exists(src)) {
            Sys.println("File not found: " + src);
            return false;
        }

        if (FileSystem.isDirectory(src)) {
            Sys.println("File is Directory: " + src);
            return false;
        }

        return true;
    }

    function convert(filePath:String, fileBytes: Bytes)
    {
        var fileType = FileUtils.distinctPixelArtFileType(fileBytes);

        switch(fileType) {
            case PixelArtFileType.Edge:
                convertEdgToGif(filePath, fileBytes);

            default:
                Sys.println("Unsupported file: " + filePath);
        }
    }

    function convertEdgToGif(filePath:String, fileBytes: Bytes)
    {
        var edgImage = EdgDecoder.decode(fileBytes);
        var gifImage = GifConverter.convertFromEdg(edgImage);
        var gifBytes = GifEncoder.encode(gifImage);

        var reg = ~/\.[0-9a-zA-Z]+$/;
        var dest = reg.replace(filePath, "") + ".gif";

        var file = File.write(dest);
        file.write(gifBytes);
        file.close();

        Sys.println("Convert edg to gif: " + filePath + " => "+ dest);
    }
}
