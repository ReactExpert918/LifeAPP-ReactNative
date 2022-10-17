import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import styled from 'styled-components/native';

import { getImagePath } from '../../../../utils/media';
import { SCREEN_WIDTH } from '../../../../constants/app';
import { MessageText } from './messageText';
import { MEDIA_FOLDER } from '../../../../services/firebase/storage';
import { images } from '../../../../assets/pngs';
import { MessageAudio } from './messageAudio';
import { MessageVideo } from './messageVideo';

const Container = styled.TouchableOpacity`
  width: 100%;
  align-items: flex-end;
  justify-content: ${(props) => (props.isOwner ? 'flex-end' : 'flex-start')};
  flex-direction: row;
  paddingHorizontal: 16px;
  paddingVertical: 5px;
`;

const HeaderImage = styled.Image`
  width: 48px;
  height: 48px;
  border-radius: 24px;
  margin-left: ${(props) => (props.isOwner ? '16px' : '0px')};
  margin-right: ${(props) => (props.isOwner ? '0px' : '16px')};
`;

const messageContent = (message, isOwner, maxWidth) => {
  const { type } = message;

  // if (type == 'pay') {
  //   return (
  //     <MessagePayComponent
  //       message={message}
  //       isOwner={isOwner}
  //       width={maxWidth}
  //     />
  //   );
  // }

  // if (type == 'photo') {
  //   return (
  //     <MessagePhotoComponent
  //       message={message}
  //       isOwner={isOwner}
  //       maxWidth={maxWidth}
  //     />
  //   );
  // }

  // if (type == 1 || type == 2 || type == 3) {
  //   return (
  //     <MessageCallComponent
  //       message={message}
  //       isOwner={isOwner}
  //       width={maxWidth}
  //     />
  //   );
  // }

  if (type == 'video') {
    return (
      <MessageVideo message={message} isOwner={isOwner} maxWidth={maxWidth} />
    );
  }

  if (type == 'audio') {
    return (
      <MessageAudio message={message} isOwner={isOwner} maxWidth={maxWidth} />
    );
  }

  return (
    <MessageText message={message} isOwner={isOwner} maxWidth={maxWidth} />
  );
};

export const Message = ({ message }) => {
  const { user } = useSelector((state) => state.Auth);

  const maxWidth = SCREEN_WIDTH - 128;

  const [avatar, setAvatar] = useState(null);
  const [isOwner, setIsOwner] = useState(false);

  useEffect(() => {
    if (message && message != {}) {
      setAvataImage(`${message.item.userId}.jpg`);
      setIsOwner(message.item.userId == user.id);
    }
  }, [message]);

  const setAvataImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.USER);

    if (path) {
      setAvatar(path);
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

Message.propTypes = {
  message: PropTypes.object,
};
