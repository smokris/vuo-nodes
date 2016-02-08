/**
 * @file
 * smokris.make.glitch.image node implementation.
 *
 * @copyright Copyright © 2016 Steve Mokris.
 * This code may be modified and distributed under the terms of the MIT License.
 */

#include "node.h"
#include <OpenGL/CGLMacro.h>

VuoModuleMetadata({
					 "title" : "Make Glitchy Image",
					 "description" : "Outputs an image containing whatever data is sitting around in the video card's RAM.",
					 "version" : "1.0.0",
				 });

void nodeEvent
(
	VuoInputData(VuoInteger, {"default":640, "suggestedMin":1, "suggestedStep":32}) width,
	VuoInputData(VuoInteger, {"default":480, "suggestedMin":1, "suggestedStep":32}) height,
	VuoOutputData(VuoImage) image
)
{
	GLuint internalFormat = VuoImageColorDepth_getGlInternalFormat(GL_BGRA, VuoImageColorDepth_8);

	// Allocate a GL texture, but don't initialize it.
	GLuint textureName;
	{
		VuoGlContext glContext = VuoGlContext_use();
		textureName = VuoGlTexturePool_use(glContext, internalFormat, width, height, GL_BGRA);
		VuoGlContext_disuse(glContext);
	}

	*image = VuoImage_make(textureName, internalFormat, width, height);
}
