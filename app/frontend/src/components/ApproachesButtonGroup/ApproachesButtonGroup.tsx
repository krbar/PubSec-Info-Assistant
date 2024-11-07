// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import { Button, ButtonGroup } from "react-bootstrap";
import { Label } from "@fluentui/react";

import styles from "./ApproachesButtonGroup.module.css";
import {Approaches} from "../../api";
import { useTranslation } from 'react-i18next';

interface Props {
    className?: string;
    onClick: (_ev: any) => void;
    defaultValue?: number;
}

export const ApproachesButtonGroup = ({ className, onClick, defaultValue }: Props) => {
    const { t } = useTranslation();
    return (
        <div className={`${styles.container} ${className ?? ""}`}>
            <Label>{t('data_source_grounding')}:</Label>
            <ButtonGroup className={`${styles.buttongroup ?? ""}`} onClick={onClick}>
                <Button id={Approaches.ReadRetrieveRead.toString()} className={`${defaultValue == Approaches.ReadRetrieveRead? styles.buttonleftactive : styles.buttonleft ?? ""}`} size="sm" value={Approaches.ReadRetrieveRead} bsPrefix='ia'>{t('chat_with_grounding')}</Button>
                <Button id={Approaches.GPTDirect.toString()} className={`${defaultValue == Approaches.GPTDirect? styles.buttonrightactive : styles.buttonmiddle ?? ""}`} size="sm" value={Approaches.GPTDirect}bsPrefix='ia'>{t('chat_with_gpt_directory')}</Button>
            </ButtonGroup>
        </div>
    );
};
