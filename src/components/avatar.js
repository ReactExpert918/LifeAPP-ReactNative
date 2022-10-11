import React from 'react';
import PropTypes from 'prop-types';
import { Image, View } from 'react-native';

const Avatar = ({ size, url }) => {
  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: size,
        overflow: 'hidden',
      }}
    >
      <Image
        source={{ uri: url }}
        style={{
          width: '100%',
          height: '100%',
        }}
      />
    </View>
  );
};

export default Avatar;

Avatar.propTypes = {
  size: PropTypes.number.isRequired,
  url: PropTypes.string,
};
