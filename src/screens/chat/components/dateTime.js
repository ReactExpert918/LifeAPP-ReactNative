import React from 'react';
import { Text } from 'react-native';
import PropTypes from 'prop-types';

import { timeForChat } from '../../../utils/datetime';

export const DateTime = ({ timeStamp, color }) => (
  <Text
    style={{
      fontSize: 10,
      color: color,
    }}
  >
    {timeForChat(timeStamp)}
  </Text>
);

DateTime.propTypes = {
  timeStamp: PropTypes.number,
  color: PropTypes.string,
};
