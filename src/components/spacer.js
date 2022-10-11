import React from 'react';
import PropTypes from 'prop-types';
import { View } from 'react-native';

const Spacer = ({ top, bottom, left, right }) => {
  return (
    <View
      style={{
        marginTop: top || 0,
        marginBottom: bottom || 0,
        marginLeft: left || 0,
        marginRight: right || 0,
      }}
    />
  );
};

export default Spacer;

Spacer.propTypes = {
  top: PropTypes.number,
  bottom: PropTypes.number,
  left: PropTypes.number,
  right: PropTypes.number,
};
