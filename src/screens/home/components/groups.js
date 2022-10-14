import React, { useState } from 'react';
import { View } from 'react-native';
import { List } from 'react-native-paper';

const Groups = () => {
  const [expand, setExpand] = useState(true);

  return (
    <List.Accordion
      title="Friends 0"
      style={{ backgroundColor: 'white' }}
      titleStyle={{ fontSize: 16, color: 'black' }}
      onPress={() => setExpand(!expand)}
      expanded={expand}
    ></List.Accordion>
  );
};

export default Groups;
