import React, { useState } from 'react';
import { Alert, Image, Text, TouchableOpacity, View } from 'react-native';
import PropTypes from 'prop-types';
import ImagePicker from 'react-native-image-crop-picker';

import {
  checkCameraPermission,
  checkPhotosPermission,
  imagePickerConfig,
} from '../../../../utils/permissions';
import { styles } from './styles';
import { Spacer } from '../../../../components';
import { textStyles } from '../../../../common/text.styles';
import { images } from '../../../../assets/pngs';
import { Button, TextInput } from 'react-native-paper';
import { colors } from '../../../../assets/colors';

export const AddAvatar = ({ onSubmit }) => {
  const [publicName, setPublicName] = useState('');
  const [image_path, setImagePath] = useState(null);

  const takePhoto = async () => {
    if (await checkCameraPermission()) {
      ImagePicker.openCamera(imagePickerConfig).then((image) => {
        setImagePath(image.path);
      });
    }
  };

  const chooseFromLibrary = async () => {
    if (await checkPhotosPermission()) {
      ImagePicker.openPicker(imagePickerConfig).then((image) => {
        setImagePath(image.path);
      });
    }
  };

  const onPhotoSelect = () => {
    Alert.alert('', 'Upload_profile_photo', [
      {
        text: 'Take_a_photo',
        onPress: () => {
          takePhoto();
        },
      },
      {
        text: 'Choose_a_photo',
        onPress: () => {
          chooseFromLibrary();
        },
      },
      {
        text: 'Cancel',
        onPress: () => {},
        style: 'destructive',
      },
    ]);
  };

  const verify = () => {
    if (!publicName) {
      Alert.alert('Attention', 'Please enter Public Name!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }
    if (!image_path) {
      Alert.alert('Attention', 'Please add Image!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }
    onSubmit(image_path, publicName);
  };

  return (
    <View style={styles.container}>
      <Text style={textStyles.blackTitleBold}>
        {'Please fill basic details\nto complete registration'}
      </Text>
      <Spacer top={16} />
      <TouchableOpacity onPress={onPhotoSelect}>
        <View style={styles.avatarContainer}>
          {image_path && (
            <Image source={{ uri: image_path }} style={styles.avatarImage} />
          )}
          <Image source={images.ic_camera} style={styles.iconImage} />
        </View>
      </TouchableOpacity>
      <View style={styles.leftContainer}>
        <Spacer top={8} />
        <Text style={textStyles.grayThin}>Public Name</Text>
        <Spacer top={2} />
        <TextInput
          mode="outlined"
          placeholder="Public Name"
          autoCapitalize="none"
          value={publicName}
          onChangeText={(text) => setPublicName(text)}
          outlineColor={'transparent'}
          activeOutlineColor={'transparent'}
          selectionColor={colors.ui.primary}
          style={{ width: '100%' }}
        />
        <Spacer top={16} />
        <Button
          mode="contained"
          color={colors.ui.primary}
          style={styles.loginButton}
          onPress={verify}
        >
          Next
        </Button>
      </View>
    </View>
  );
};

AddAvatar.propTypes = {
  onSubmit: PropTypes.func.isRequired,
};
