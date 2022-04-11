import React, { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import RNFS from "react-native-fs";
import styled from "styled-components/native";
import { images } from "../../../../images";
import { firebaseSDK } from "../../../../libs/firebase";
import { MessageTextComponent } from "./message-text.component";
import { Dimensions } from "react-native";

const Container = styled.TouchableOpacity`
  width: 100%;
  align-items: flex-end;
  justify-content: ${(props) => (props.isOwner ? "flex-end" : "flex-start")};
  flex-direction: row;
  padding: ${(props) => props.theme.spaces[2]};
`;

const HeaderImage = styled.Image`
  width: 48px;
  height: 48px;
  border-radius: 24px;
  margin-left: ${(props) => (props.isOwner ? props.theme.spaces[2] : "0px")};
  margin-right: ${(props) => (props.isOwner ? "0px" : props.theme.spaces[2])};
`;

const messageContent = (message, isOwner, maxWidth) => {
  const { type } = message;

  return (
    <MessageTextComponent
      message={message}
      isOwner={isOwner}
      maxWidth={maxWidth}
    />
  );
};

export const MessageComponent = ({ message }) => {
  const { user } = useSelector((state) => state.login_state);

  const maxWidth = Dimensions.get("window").width - 128;
  console.log(maxWidth);

  const [avatar, setAvatar] = useState(null);
  const [isOwner, setIsOwner] = useState(false);

  useEffect(() => {
    if (message && message != {}) {
      console.log(message);
      downloadImage(`${message.item.userId}.jpg`);
      setIsOwner(message.item.userId == user.id);
    }
  }, [message]);

  const downloadImage = async (fileName) => {
    const filePath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
    const exists = await RNFS.exists(filePath);
    if (exists) {
      setAvatar(filePath);
    } else {
      const url = await firebaseSDK.getDownloadURL(
        `${MEDIA_FOLDER.USER}/${fileName}`
      );
      RNFS.downloadFile({ fromUrl: url, toFile: filePath })
        .promise.then((r) => {
          console.log(r);
          setAvatar(filePath);
        })
        .catch((error) => {
          console.log(error);
        });
    }
  };

  return (
    <Container isOwner={isOwner}>
      {isOwner && messageContent(message.item, isOwner, maxWidth)}
      <HeaderImage
        source={avatar ? { uri: avatar } : images.ic_default_profile}
        isOwner={isOwner}
      />
      {!isOwner && messageContent(message.item, isOwner, maxWidth)}
    </Container>
  );
};
