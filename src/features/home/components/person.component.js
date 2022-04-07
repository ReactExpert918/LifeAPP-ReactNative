import React, { useEffect, useState } from "react";
import styled from "styled-components/native";
import { Text } from "../../../components/typography/text.component";
import { images } from "../../../images";
import { colors } from "../../../infrastructures/theme/colors";
import RNFS from "react-native-fs";
import { MEDIA_FOLDER } from "../../../libs/firebase/storage";
import { firebaseSDK } from "../../../libs/firebase";

const Container = styled.View`
  height: 80px;
  width: 100%;
  align-items: center;
  justify-content: center;
  flex-direction: row;
  padding: ${(props) => props.theme.spaces[2]};
`;

const HeaderImage = styled.Image`
  width: 48px;
  height: 48px;
  border-radius: 24px;
  margin-right: ${(props) => props.theme.spaces[2]};
`;

const TextContainer = styled.View`
  flex: 1;
  align-items: flex-start;
  justify-content: center;
`;

export const PERSONCELLTYPE = {
  group: "group",
  friend: "friend",
  chats: "chats",
  group_header: "header",
  user: "user",
};

export const PersonComponent = ({ CELLInfo }) => {
  const [image_uri, setImage_url] = useState(null);
  const [title, setTitle] = useState(null);
  const [message, setMessage] = useState(null);
  const [name, setName] = useState(null);
  const { type } = CELLInfo;

  useEffect(() => {
    if (CELLInfo && CELLInfo != {}) {
      //downloadImage(`${user_id}.jpg`);
      if (type == PERSONCELLTYPE.user) {
        const titleNew =
          CELLInfo.fullname ??
          CELLInfo.username ??
          CELLInfo.email ??
          CELLInfo.phone;
        setTitle(titleNew);
        const messageNew = CELLInfo.about;
        setMessage(messageNew);
        downloadImage(`${CELLInfo.id}.jpg`);
      } else if (type == PERSONCELLTYPE.group_header) {
        setTitle(CELLInfo.title);
        setMessage(CELLInfo.message);
      } else if (type == PERSONCELLTYPE.group) {
        setName(CELLInfo.name);
        downloadImage(`${CELLInfo.objectId}.jpg`);
      } else if (type == PERSONCELLTYPE.friend) {
        const nameNew =
          CELLInfo.fullname ??
          CELLInfo.username ??
          CELLInfo.email ??
          CELLInfo.phone;

        setName(nameNew);
        downloadImage(`${CELLInfo.objectId}.jpg`);
      } else if (type == PERSONCELLTYPE.chats) {
        setChatsContent();
        downloadImage(`${CELLInfo.user_id}.jpg`);
      }
    }
  }, [CELLInfo]);

  const setChatsContent = async () => {
    if (CELLInfo.isGroup) {
      const group = await firebaseSDK.getGroup(CELLInfo.user_id);
      if (group) {
        setTitle(group.name);
        setMessage(CELLInfo.text);
      }
    } else {
      const person = await firebaseSDK.getUser(CELLInfo.user_id);
      if (person) {
        const titleNew =
          person.fullname ?? person.username ?? person.email ?? person.phone;
        setTitle(titleNew);
        const messageNew = person.about;
        setMessage(messageNew);
      }
    }
  };

  const downloadImage = async (fileName) => {
    const filePath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
    const exists = await RNFS.exists(filePath);
    if (exists) {
      setImage_url(filePath);
    } else {
      const url = await firebaseSDK.getDownloadURL(
        `${MEDIA_FOLDER.USER}/${fileName}`
      );
      RNFS.downloadFile({ fromUrl: url, toFile: filePath })
        .promise.then((r) => {
          console.log(r);
          setImage_url(filePath);
        })
        .catch((error) => {
          console.log(error);
        });
    }
  };

  return (
    <Container>
      {type == PERSONCELLTYPE.group_header ? (
        <HeaderImage source={images.ic_create_group} />
      ) : image_uri ? (
        <HeaderImage source={{ uri: image_uri }} />
      ) : (
        <HeaderImage source={images.ic_default_profile} />
      )}
      <TextContainer>
        {title && (
          <>
            <Text variant="label" color={colors.text.black}>
              {title}
            </Text>
            <Text variant="hint" color={colors.text.gray}>
              {message}
            </Text>
          </>
        )}
        {name && (
          <Text variant="label" color={colors.text.black}>
            {name}
          </Text>
        )}
      </TextContainer>
    </Container>
  );
};
