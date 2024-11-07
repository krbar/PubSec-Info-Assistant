// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import React, { useEffect, useMemo, useState } from "react";
import { Text } from "@fluentui/react";
import { Label } from '@fluentui/react/lib/Label';
import { Separator } from '@fluentui/react/lib/Separator';
import { getInfoData, GetInfoResponse } from "../../api";
import { useTranslation } from 'react-i18next';

interface Props {
    className?: string;
    item?: any;
}
interface Stat {
    status_timestamp: string;
    status: string; // replace 'string' with the actual type of 'timestamp'
    // include other properties of 'stat' here
}
export const StatusContent = ({ item }: Props) => {
    const { t } = useTranslation();
    const data = item.status_updates.reverse();
    // .sort((a: any, b: any) => new Date(b.status_timestamp).getTime() - new Date(a.status_timestamp).getTime());
    const DisplayData=data.map(
        (stat: Stat)=>{
            return(
                <tr>
                    <td>{stat.status}</td>
                    <td>{stat.status_timestamp.toString()}</td>
                </tr>
            )
        }
    )
    
    return (
        <div>
            <Label>File Name</Label><Text>{item?.name}</Text>
            <table className="table table-striped">
                <thead>
                    <tr>
                    <th>{t('status')}</th>
                    <th>{t('timestamp')}</th>
                    </tr>
                </thead>
                <tbody>
                    {DisplayData}
                </tbody>
            </table>
        </div>
    );
};