/**
 * @file
 * smokris.macam.receive node implementation.
 *
 * @copyright Copyright © 2020 Steve Mokris.
 * This code may be modified and distributed under the terms of GPL2
 * (inherited from macam, which is GPL2).
 */

#include "node.h"
#include "VuoApp.h"

#include <OpenGL/OpenGL.h>
#include <OpenGL/CGLMacro.h>

#define NS_RETURNS_INNER_POINTER
#include "MyCameraCentral.h"

VuoModuleMetadata({
	"title": "Receive Webcam Video",
	"keywords": [
		"usb",
		"camera", "capture", "streaming", "record",
		"CPiA", "VLSI Vision", "Intel Play QX3 microscope",
	],
	"version": "1.0.0",
	"dependencies": [
		"IOKit.framework",
		"VuoApp",
		"macam64",
	],
});

struct nodeInstanceData
{
	MyCameraDriver *cam;
	void (*receivedImage)(VuoImage image);
	bool triggersEnabled;
};

@interface SMokrisMacamDelegate : NSObject
{
	struct nodeInstanceData *_context;
}
@end
@implementation SMokrisMacamDelegate

- (id)initWithNode:(struct nodeInstanceData *)context
{
	if (self = [super init])
	{
		_context = context;
	}
	return self;
}

- (void)imageReady:(MyCameraDriver *)cam
{
	if (_context->triggersEnabled && _context->receivedImage)
	{
		// Flip
		unsigned char *in = cam.imageBuffer;
		unsigned char *pixels = (unsigned char *)malloc(cam.width*cam.height*3);
		short height = cam.height;
		short stride = cam.imageBufferRowBytes;
		for (short y = 0; y < height; ++y)
			memcpy(pixels + y * stride, in + (height - y - 1) * stride, stride);
		VuoImage image = VuoImage_makeFromBuffer(pixels, GL_RGB, cam.width, cam.height, VuoImageColorDepth_8, ^(void *pixels){
			free(pixels);
		});
		_context->receivedImage(image);
	}

	free(cam.imageBuffer);

	[cam setImageBuffer:malloc(cam.width*cam.height*3*2) bpp:3 rowBytes:cam.imageBufferRowBytes];
}

- (void)cameraEventHappened:(id)sender event:(CameraEvent)evt
{
	if (evt == CameraEventSnapshotButtonDown)
		VUserLog("CameraEventSnapshotButtonDown");
	else if (evt == CameraEventSnapshotButtonUp)
		VUserLog("CameraEventSnapshotButtonUp");
	else
		VLog("unknown event");
}

- (void)grabFinished:(id)sender withError:(CameraError)err
{
	VL();
}

- (void)cameraHasShutDown:(id)sender
{
	VL();
}

@end

#define LogFeature(feature) if ([cam feature]) VUserLog("    %s", #feature);
#define LogResolution(resolution, wh) if ([cam findFrameRateForResolution:resolution] > 0) VUserLog("    Supports %-15s (%-11s) @ %d fps", #resolution, #wh, [cam findFrameRateForResolution:resolution]);

struct nodeInstanceData *nodeInstanceInit(
	VuoInputData(VuoInteger) device,
	VuoInputData(VuoInteger) width,
	VuoInputData(VuoInteger) height,
	VuoInputData(VuoBoolean) setTopLight,
	VuoInputData(VuoBoolean) setBottomLight)
{
	struct nodeInstanceData *context = (struct nodeInstanceData *)calloc(1, sizeof(struct nodeInstanceData));
	VuoRegister(context, free);

	MyCameraCentral *cc = [MyCameraCentral sharedCameraCentral];
	if (![cc startupWithNotificationsOnMainThread:NO recognizeLaterPlugins:NO])
	{
		VUserLog("Macam startup failed");
		goto done;
	}

	VUserLog("Cameras currently connected: %d", cc.numCameras);
	for (int i = 0; i < cc.numCameras; ++i)
		VUserLog("    Device %d = '%s'", i, [cc nameForID:[cc idOfCameraWithIndex:i]].UTF8String);

	unsigned long cid = [cc idOfCameraWithIndex:device];
	if (cid == 0)
	{
		VUserLog("Camera %lld not found", device);
		goto done;
	}

	MyCameraDriver *cam = nil;
	CameraError err = [cc useCameraWithID:cid to:&cam acceptDummy:NO];
	if (err != CameraErrorOK)
	{
		VUserLog("Macam couldn't open camera: error %d (%s)", err, [cc localizedCStrForError:err]);
		goto done;
	}
	context->cam = cam;

	CameraResolution r = [cam findResolutionForWidth:width height:height];
	short fr = [cam findFrameRateForResolution:r];
	VLog("res %d = %d",r,[cam supportsResolution:r fps:fr]);
	[cam setResolution:r fps:fr];

	VUserLog("Selected '%s'%s    %dx%d @ %d fps    realCamera=%d",
		[cam.class cameraName].UTF8String,
		cam.hasSpecificName ? VuoText_format(" ('%s')", cam.getSpecificName.UTF8String) : "", 
		cam.width, cam.height, cam.fps, cam.realCamera);

	LogFeature(canSetBrightness);
	LogFeature(canSetOffset);
	LogFeature(canSetContrast);
	LogFeature(canSetSaturation);
	LogFeature(canSetHue);
	LogFeature(canSetGamma);
	LogFeature(canSetSharpness);
	LogFeature(canSetGain);
	LogFeature(canSetShutter);
	LogFeature(canSetAutoGain);
	LogFeature(canSetLed);
	LogFeature(canSetOrientationTo:NormalOrientation);
	LogFeature(canSetOrientationTo:FlipHorizontal);
	LogFeature(canSetOrientationTo:InvertVertical);
	LogFeature(canSetOrientationTo:Rotate180);
	LogFeature(canSetHFlip);
	LogFeature(canSetFlicker);
	LogFeature(canSetUSBReducedBandwidth);
	LogFeature(canSetWhiteBalanceMode);
	LogFeature(canSetWhiteBalanceModeTo:WhiteBalanceLinear)
	LogFeature(canSetWhiteBalanceModeTo:WhiteBalanceIndoor)
	LogFeature(canSetWhiteBalanceModeTo:WhiteBalanceOutdoor)
	LogFeature(canSetWhiteBalanceModeTo:WhiteBalanceAutomatic)
	LogFeature(canSetWhiteBalanceModeTo:WhiteBalanceManual)
	LogFeature(canBlackWhiteMode);
	LogFeature(canStoreMedia);

	LogResolution(ResolutionSQSIF,  128 x  96 );
	LogResolution(ResolutionQSIF ,  160 x 120 );
	LogResolution(ResolutionQCIF ,  176 x 144 );
	LogResolution(ResolutionSIF  ,  320 x 240 );
	LogResolution(ResolutionCIF  ,  352 x 288 );
	LogResolution(ResolutionVGA  ,  640 x 480 );
	LogResolution(ResolutionSVGA ,  800 x 600 );
	LogResolution(ResolutionXGA  , 1024 x 768 );
	LogResolution(ResolutionUXGA , 1600 x 1200);

	SMokrisMacamDelegate *qd = [[SMokrisMacamDelegate alloc] initWithNode:context];
	[cam setDelegate:qd];

	[cam startGrabbing];
	if (!cam.isGrabbing)
	{
		VUserLog("Macam couldn't start grabbing");
		goto done;
	}

	[cam setImageBuffer:malloc(cam.width*cam.height*3*2) bpp:3 rowBytes:cam.width*3];

	if ([cam respondsToSelector:@selector(setTopLight:)])
		[cam performSelector:@selector(setTopLight:) withObject:(id)setTopLight];
	if ([cam respondsToSelector:@selector(setBottomLight:)])
		[cam performSelector:@selector(setBottomLight:) withObject:(id)setBottomLight];

done:
	return context;
}

void nodeInstanceTriggerStart(
	VuoInstanceData(struct nodeInstanceData *) context,
	VuoOutputTrigger(receivedImage, VuoImage, {"eventThrottling":"drop"})
)
{
	(*context)->triggersEnabled = true;
	(*context)->receivedImage = receivedImage;
}

void nodeInstanceEvent(
	VuoInstanceData(struct nodeInstanceData *) context,

	VuoInputData(VuoInteger, {"suggestedMin":0, "suggestedMax":15}) device,
	VuoInputData(VuoInteger) width,
	VuoInputData(VuoInteger) height,

	VuoInputData(VuoBoolean) setTopLight,
	VuoInputEvent({"data":"setTopLight"}) setTopLightEvent,
	VuoInputData(VuoBoolean) setBottomLight,
	VuoInputEvent({"data":"setBottomLight"}) setBottomLightEvent
)
{
	if ((setTopLightEvent || setBottomLightEvent)
		&& [(*context)->cam respondsToSelector:@selector(setTopLight:)]
		&& [(*context)->cam respondsToSelector:@selector(setBottomLight:)])
	{
		[(*context)->cam performSelector:@selector(setTopLight:) withObject:(id)setTopLight];
		[(*context)->cam performSelector:@selector(setBottomLight:) withObject:(id)setBottomLight];
	}
}

void nodeInstanceTriggerStop(VuoInstanceData(struct nodeInstanceData *) context)
{
	(*context)->receivedImage = NULL;
	(*context)->triggersEnabled = false;
}

void nodeInstanceFini(VuoInstanceData(struct nodeInstanceData *) context)
{
	if ((*context)->cam)
	{
		[(*context)->cam stopGrabbing];
		[(*context)->cam shutdown];

		id delegate = (*context)->cam.delegate;
		(*context)->cam.delegate = nil;
		[delegate release];
	}
}
