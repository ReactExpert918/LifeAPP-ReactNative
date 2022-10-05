import { React, useState } from "react"
import { SectionComponent } from "./component/sectionComponent"
import { PersonComponent } from "./component/personComponent"

export const FriendSection = ({title, items, onNavigate, visible}) => {
    const [showContent, setShowContent] = useState(true);

    const onClick = () => {
        const show = !showContent;
        setShowContent(show);
    };

    return (
        <>
            <SectionComponent
                showContent={showContent}
                title={`${title} ${
                title == "Groups" ? items.length - 1 : items.length
                }`}
                onClick={onClick}
            />
            {showContent &&
                items.map((data, index) => {
                return (
                    <PersonComponent
                        CELLInfo={data}
                        key={`data-${index}`}
                        onNavigate={onNavigate}
                        click={visible}
                    />
                );
                })}
        </>
    );
}