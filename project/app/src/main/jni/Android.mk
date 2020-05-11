LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE				:= libracket3m
LOCAL_SRC_FILES 			:= $(LOCAL_PATH)/racket/libracket3m.a
LOCAL_EXPORT_C_INCLUDES		:= $(LOCAL_PATH)/racket/include

include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE				:= librktio
LOCAL_SRC_FILES 			:= $(LOCAL_PATH)/racket/librktio.a
LOCAL_EXPORT_C_INCLUDES		:= $(LOCAL_PATH)/racket/include

include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE    := racket-android-project

LOCAL_CFLAGS  += -O1 -D_FORTIFY_SOURCE=2
LOCAL_C_INCLUDES := $(LOCAL_PATH)/racket/include
LOCAL_LDLIBS := -lGLESv3 -lEGL -llog
LOCAL_LDFLAGS += -rdynamic

LOCAL_SRC_FILES := racket-android-project.c

LOCAL_STATIC_LIBRARIES := libracket3m librktio libffi

#LOCAL_SHARED_LIBRARIES := sfml-system-d
#LOCAL_SHARED_LIBRARIES += sfml-window-d
#LOCAL_SHARED_LIBRARIES += sfml-graphics-d
#LOCAL_SHARED_LIBRARIES += sfml-audio-d
#LOCAL_SHARED_LIBRARIES += sfml-network-d

include $(BUILD_SHARED_LIBRARY)


$(call import-module,third_party/sfml)
$(call import-module,third_party/libffi)