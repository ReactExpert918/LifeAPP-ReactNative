/* eslint-disable react/jsx-key */
import React, { useEffect, useState } from 'react';
import styled from 'styled-components/native';
import PropTypes from 'prop-types';
import Video from 'react-native-video';

import { Spacer } from '../../../../components';
import { DateTime } from '../dateTime';
import { colors } from '../../../../assets/colors';
import { getImagePath } from '../../../../utils/media';
import { MEDIA_FOLDER } from '../../../../services/firebase/storage';

const Container = styled.View`
  padding: 8px;
  align-items: flex-end;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
  border-bottom-left-radius: ${(props) => (props.isOwner ? '12px' : '0px')};
  border-bottom-right-radius: ${(props) => (props.isOwner ? '0px' : '12px')};
`;

export const MessageVideo = ({ message, isOwner, maxWidth }) => {
  const [videoUrl, setVideoUrl] = useState(null);

  useEffect(() => {
    if (!message.chatId) return;
    setImage(`${message.chatId}.mp4`);
  }, [message]);

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.MEDIA);
    if (path) {
      setVideoUrl(path);
    }
  };

  return (
    <Container isOwner={isOwner} maxWidth={maxWidth}>
      {videoUrl && (
        <Video
          source={{
            // uri: videoUrl,
            uri: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          }} // Store reference
          style={{
            width: 120,
            height: 120,
            borderRadius: 120,
            backgroundColor: 'grey',
          }}
        />
      )}

      <Spacer top={16} />

      <DateTime
        color={isOwner ? colors.text.white : colors.text.gray}
        timeStamp={message.createdAt}
      />
    </Container>
  );
};

MessageVideo.propTypes = {
  message: PropTypes.string,
  isOwner: PropTypes.bool,
  maxWidth: PropTypes.number,
};
