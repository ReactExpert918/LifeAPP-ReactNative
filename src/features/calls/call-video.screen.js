import React, { useEffect, useRef, useState } from "react";

import {
  Platform,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
import RtcEngine, {
  RtcLocalView,
  RtcRemoteView,
  VideoRenderMode,
} from "react-native-agora";

import { AGORA_APP_ID } from "../../constants/app";

import { Dimensions, StyleSheet } from "react-native";
import {
  checkCameraPermission,
  checkMicPermission,
} from "../../utils/permissions";
import database from "@react-native-firebase/database";

const dimensions = {
  width: Dimensions.get("window").width,
  height: Dimensions.get("window").height,
};

const styles = StyleSheet.create({
  max: {
    flex: 1,
  },
  buttonHolder: {
    height: 100,
    alignItems: "center",
    flex: 1,
    flexDirection: "row",
    justifyContent: "space-evenly",
  },
  button: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: "#0093E9",
    borderRadius: 25,
  },
  buttonText: {
    color: "#fff",
  },
  fullView: {
    width: dimensions.width,
    height: dimensions.height - 100,
  },
  remoteContainer: {
    width: "100%",
    height: 150,
    position: "absolute",
    top: 5,
  },
  remote: {
    width: 150,
    height: 150,
    marginHorizontal: 2.5,
  },
  noUserText: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    color: "#0093E9",
  },
  padding: {
    paddingHorizontal: 2.5,
  },
});

export const VideoCallScreen = ({ navigation, route }) => {
  console.log(route);
  const { chatId, receptId, outGoing } = route.params;
  const _engine = useRef(null);
  const [isJoined, setJoined] = useState(false);
  const [peerIds, setPeerIds] = useState([]);

  useEffect(() => {
    /**
     * @name init
     * @description Function to initialize the Rtc Engine, attach event listeners and actions
     */
    const init = async () => {
      await checkCameraPermission();
      await checkMicPermission();
      _engine.current = await RtcEngine.create(AGORA_APP_ID);
      await _engine.current.enableVideo();
      _engine.current.addListener("Warning", (warn) => {
        console.log("Warning", warn);
      });

      _engine.current.addListener("Error", (err) => {
        console.log("Error", err);
      });

      _engine.current.addListener("UserJoined", (uid, elapsed) => {
        console.log("UserJoined", uid, elapsed);
        // If new user
        if (peerIds.indexOf(uid) === -1) {
          // Add peer ID to state array
          setPeerIds((prev) => [...prev, uid]);
        }
      });

      _engine.current.addListener("UserOffline", (uid, reason) => {
        console.log("UserOffline", uid, reason);
        // Remove peer ID from state array
        setPeerIds((prev) => prev.filter((id) => id !== uid));
      });

      // If Local user joins RTC channel
      _engine.current.addListener(
        "JoinChannelSuccess",
        (channel, uid, elapsed) => {
          console.log("JoinChannelSuccess", channel, uid, elapsed);
          // Set state variable to true
          setJoined(true);
        }
      );
    };
    init();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const startCall = async () => {
    // Join Channel using null token and channel name
    console.log("Start Call");
    database().ref(`/video_call/${chatId}`).set({
      receiver: receptId,
      status: 4,
    });
    await _engine.current?.joinChannel("", chatId, null, 0);
  };

  /**
   * @name endCall
   * @description Function to end the call
   */
  const endCall = async () => {
    await _engine.current?.leaveChannel();
    setPeerIds([]);
    setJoined(false);
  };

  const _renderVideos = () => {
    return isJoined ? (
      <View style={styles.fullView}>
        <RtcLocalView.SurfaceView
          style={styles.max}
          channelId={chatId}
          renderMode={VideoRenderMode.Hidden}
        />
        {_renderRemoteVideos()}
      </View>
    ) : null;
  };

  const _renderRemoteVideos = () => {
    return (
      <ScrollView
        style={styles.remoteContainer}
        contentContainerStyle={styles.padding}
        horizontal={true}
      >
        {peerIds.map((value) => {
          return (
            <RtcRemoteView.SurfaceView
              style={styles.remote}
              uid={value}
              channelId={chatId}
              renderMode={VideoRenderMode.Hidden}
              zOrderMediaOverlay={true}
            />
          );
        })}
      </ScrollView>
    );
  };

  return (
    <View style={styles.max}>
      <View style={styles.max}>
        <View style={styles.buttonHolder}>
          <TouchableOpacity onPress={startCall} style={styles.button}>
            <Text style={styles.buttonText}> Start Call </Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={endCall} style={styles.button}>
            <Text style={styles.buttonText}> End Call </Text>
          </TouchableOpacity>
        </View>
        {_renderVideos()}
      </View>
    </View>
  );
};
