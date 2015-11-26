class VideoControllerExtend extends VideoController

	getVideoInstance: (i) =>
		return new VideoExtend(i)

