import React, { useState } from 'react';
import { View } from 'react-native';
import { List } from 'react-native-paper';
import { CreateGroup } from '../../friend/createGroup';

const Friends = () => {
  const [expand, setExpand] = useState(true);

  return (
    <List.Accordion
      title="Groups 0"
      style={{ backgroundColor: 'white' }}
      titleStyle={{ fontSize: 16, color: 'black' }}
      onPress={() => setExpand(!expand)}
      expanded={expand}
    >
      <CreateGroup />
    </List.Accordion>
  );
};

export default Friends;
