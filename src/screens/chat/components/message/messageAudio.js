/* eslint-disable react/jsx-key */
import React, { useEffect, useState } from 'react';
import styled from 'styled-components/native';
import PropTypes from 'prop-types';

import { AudioPlayer, Spacer } from '../../../../components';
import { DateTime } from '../dateTime';
import { colors } from '../../../../assets/colors';
import { PauseIcon, PlayIcon } from '../../../../assets/svgs';
import { getImagePath } from '../../../../utils/media';
import { MEDIA_FOLDER } from '../../../../services/firebase/storage';

const Container = styled.View`
  padding: 8px;
  max-width: ${(props) => props.maxWidth};
  align-items: flex-end;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
  border-bottom-left-radius: ${(props) => (props.isOwner ? '12px' : '0px')};
  border-bottom-right-radius: ${(props) => (props.isOwner ? '0px' : '12px')};
  background-color: ${(props) =>
    props.isOwner ? colors.ui.secondary : colors.bg.lightgray}};
`;

export const MessageAudio = ({ message, isOwner, maxWidth }) => {
  const [audioUrl, setAudioUrl] = useState(null);

  useEffect(() => {
    if (!message.objectId) return;
    setImage(`${message.objectId}.m4a`);
  }, [message]);

  const setImage = async (fileName) => {
    const path = await getImagePath(fileName, MEDIA_FOLDER.MEDIA);
    if (path) {
      setAudioUrl(path);
    }
  };

  return (
    <Container isOwner={isOwner} maxWidth={maxWidth}>
      {audioUrl && (
        <AudioPlayer
          color="#ff6651"
          customStyles={{
            durationText: { color: colors.ui.white },
            playControl: { marginRight: 10 },
          }}
          width={120}
          icons={[<PlayIcon />, <PauseIcon />]}
          video={{ uri: audioUrl }}
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

MessageAudio.propTypes = {
  message: PropTypes.string,
  isOwner: PropTypes.bool,
  maxWidth: PropTypes.number,
};
