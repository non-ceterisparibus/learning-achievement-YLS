import pandas as pd
import numpy as np

def home_inputs():
    barc = pd.read_stata("data/barchart.dta")
    barc=barc[['region','round','avg_hq_new','avg_cd_new','avg_sv_new']]
    barc.drop_duplicates(inplace=True)

    barc['region']=barc['region'].replace({'Northern Uplands':"LC","Red River Delta":"HY",'Phu Yen':"PY",'Da Nang':"DN","Mekong River Delta":"BT"})
    barc=barc[(~barc['region'].isin(['Highlands','South Eastern','Other']))&(~barc['region'].isna())]
    df=pd.wide_to_long(barc,stubnames='avg_',i=['region','round'],j='index',suffix=r'\w+')
    df.reset_index(inplace=True)
    df['index'] = df['index'].replace({'hq_new':"Housing quality",'sv_new':"Access-to-service",'cd_new':'Consumer durables'})

    return df

def schl_inputs():
    # Import data
    df = pd.read_stata("data/barchart.dta")
    schl = df[['region','round','avg_facidx','avg_seridx','avg_device']]
    schl=schl[schl['round'].isin([3,5])]
    schl.drop_duplicates(inplace=True)
    schl['region']=schl['region'].replace({'Northern Uplands':"LC","Red River Delta":"HY",'Phu Yen':"PY",'Da Nang':"DN","Mekong River Delta":"BT"})

    schl=schl[~schl['region'].isin(['Highlands','South Eastern','Other'])&(~schl['region'].isna())]
    df=pd.wide_to_long(schl,stubnames='avg_',i=['region','round'],j='index',suffix=r'\w+')
    df.reset_index(inplace=True)
    df['index'] = l['index'].replace({'facidx':"Basic facilitiex",'seridx':"Access-to-service",'device':'School devices'})
    df['round'] = l['round'].replace({3:"Primary",5:"Secondary"})
    df.rename(columns={"round":"school level"},inplace=True)
    
    return df