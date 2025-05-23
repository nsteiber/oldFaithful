
----------Set Primary Alliance----------------
IF OBJECT_ID ('tempdb..#primary_mid') IS NOT NULL
DROP TABLE #primary_mid
Select M.MEMBER_ID,m.COMPANY_ID,m.SALES_INDICATOR,m.SALESPCT,m.Quota_ActMgr_FullName,m.Quota_Division_ID,m.DIVISION_ID
INTO #primary_mid
From Provista..Member_Company_Provista as M
where SALES_INDICATOR in ('Y') and SALESPCT = 100 --and MEMBER_STATUS_DESC in ('Active')

---------Member Grouping - Channel Partner/Aggregation Grouping---------------
IF OBJECT_ID ('tempdb..#MC_Group') IS NOT NULL
DROP TABLE #MC_Group
Select MC.Company_ID, MC.Member_ID, MC.Member_Name, MC.Group_Type, MC.Group_Sub_Type, MC.Group_Sub_Type_Cd, MC.Group_Sub_Type_Name, MC.Eff_Start_Date, MC.Eff_End_Date
                    ,Is_Active,Is_Current,Is_Primary,m.SALES_INDICATOR,m.SALESPCT
					,CASE WHEN SALES_INDICATOR in ('Y') and SALESPCT = 100 then 'Primary' else Null end as 'Primary_Member_Alliance'
INTO #MC_Group
From PROVISTA..MC_Group_Sub_Type as MC left join #primary_mid as M on MC.Company_ID = M. COMPANY_ID and MC.Member_ID = M.MEMBER_ID
WHERE  MC.Is_Active = 1 and MC.Is_Primary = 1 and MC.Is_Current = 1 and SALES_INDICATOR in ('Y') and SALESPCT = 100 and Group_Type not in ('Aggregation Group')

-----------Member Group Checkpoint----------------
--select top (10) * from #MC_Group 



-----------PRS Summary-------------

Declare @ClosePY date,@CloseCY date, @LTM date

Select @ClosePY = DATEADD(year,-1,Max(Receipt_Date)) 
       FROM Provista.dbo.PRS_Detail Where Company_ID = '019';
Select @CloseCY = Max(Receipt_Date)
       FROM Provista.dbo.PRS_Detail Where Company_ID = '019';
Select @LTM = DATEADD(month,-11,Max(Receipt_Date))
       FROM Provista.dbo.PRS_Detail Where Company_ID = '019'

IF OBJECT_ID ('tempdb..#PRS') IS NOT NULL
DROP TABLE #PRS
Select 
  MCP.Member_ID
, MCP.Company_ID
--,c.PROD_SEG_ID

--,c.VENDOR_NAME
--,c.CONTRACT_ID
--, c.Spend_Mgmt_Domain
 
	   --,sum(case when receipt_date between '1/1/2022' and '12/31/2022' then Revenue else 0 END) AS 'Rev_22_PRS'
       --,sum(case when receipt_date between '1/1/2023' and '12/31/2023' then Revenue else 0 END) AS 'Rev_23_PRS'
	   ,sum(case when receipt_date between '1/1/2024' and '12/31/2024' then Revenue else 0 END) AS 'Rev_24_PRS'
	   
       --,sum(case when receipt_date between '1/1/2023' and @ClosePY then Revenue else 0 END) AS 'Rev_23_YTD_PRS'
	 
	 

INTO #PRS
From PROVISTA..Member_Company_Provista MCP 
INNER JOIN PROVISTA..PRS_Detail PRS ON MCP.COMPANY_ID = PRS.Company_ID and MCP.MEMBER_ID = PRS.Member_ID 
INNER JOIN PROVISTA..LKP_Contract C on PRS.CONTRACT_ID = C.CONTRACT_ID
WHERE C.Finance_Filter = 'N'  and Rpt_Type = 'Current' --and MCP.Division_ID like ('P%') and MCP.Division_ID <> 'PM' --in ('PI','PB','PC','PF','PI','PS','PU','PG','PV','PZ','PY')
--and (mcp.company_id in ('019') or (mcp.Quota_Division_ID like ('P%') and mcp.Quota_Division_ID not in ('PM')))
--and PRS.Receipt_Date > '1/1/2021'
Group By  
   MCP.Member_ID
  ,MCP.Company_ID
--,c.PROD_SEG_ID
--,c.VENDOR_NAME
--,c.CONTRACT_ID
--,c.Spend_Mgmt_Domain



IF OBJECT_ID ('tempdb..#PRS_NAF') IS NOT NULL
DROP TABLE #PRS_NAF
Select 
  MCP.Member_ID
, MCP.Company_ID
--,c.PROD_SEG_ID

--,c.VENDOR_NAME
--,c.CONTRACT_ID
--, c.Spend_Mgmt_Domain
 
	   ,sum(case when receipt_date between '1/1/2022' and '12/31/2022' then Receipt_Revenue else 0 END) AS 'GRev_22'
       ,sum(case when receipt_date between '1/1/2023' and '12/31/2023' then Receipt_Revenue else 0 END) AS 'GRev_23'
	   
       ,sum(case when receipt_date between '1/1/2023' and @ClosePY then Receipt_Revenue else 0 END) AS 'GRev_23_YTD'
	    ,sum(case when receipt_date between '1/1/2024' and '12/31/2024' then Receipt_Revenue else 0 END) AS 'GRev_24'

	   
	   ,sum(case when receipt_date between '1/1/2022' and '12/31/2022' then Contracted_Net_Revenue else 0 END) AS 'CNAF_Rev_22'
       ,sum(case when receipt_date between '1/1/2023' and @ClosePY then Contracted_Net_Revenue else 0 END) AS 'CNAF_Rev_23_YTD'
	   ,sum(case when receipt_date between '1/1/2024' and @CloseCY then Contracted_Net_Revenue else 0 END) AS 'CNAF_Rev_24'

	   ,sum(case when receipt_date between '1/1/2023' and '12/31/2023' then Contracted_Net_Revenue else 0 END) AS 'CNAF_Rev_23_Total'
	


INTO #PRS_NAF
From PROVISTA..Member_Company_Provista MCP 
INNER JOIN PROVISTA..PRS_Contracted_Net_Revenue PRSNAF ON MCP.COMPANY_ID = PRSNAF.Company_ID and MCP.MEMBER_ID = PRSNAF.Member_ID 
INNER JOIN PROVISTA..LKP_Contract C on PRSNAF.CONTRACT_ID = C.CONTRACT_ID
WHERE C.Finance_Filter = 'N'  and Rpt_Type = 'Current' --and MCP.Division_ID like ('P%') and MCP.Division_ID <> 'PM' --in ('PI','PB','PC','PF','PI','PS','PU','PG','PV','PZ','PY')
--and (mcp.company_id in ('019') or (mcp.Quota_Division_ID like ('P%') and mcp.Quota_Division_ID not in ('PM')))
--and PRS.Receipt_Date > '1/1/2021'
Group By  
   MCP.Member_ID
  ,MCP.Company_ID
--,c.PROD_SEG_ID
--,c.VENDOR_NAME
--,c.CONTRACT_ID
--,c.Spend_Mgmt_Domain



--IF OBJECT_ID ('tempdb..#IFS') IS NOT NULL
--DROP TABLE #IFS
--Select Company_ID, Member_ID
--	  ,sum(case when Month_ID between '202200' and '202203' then Total_Fee_Share_Amt else 0 END) AS 'FS_22'
--      ,sum(case when Month_ID between '202300' and '202303' then Total_Fee_Share_Amt else 0 END) AS 'FS_23'
--    ,sum(case when Month_ID between '202400' and '202403' then Total_Fee_Share_Amt else 0 END) AS 'FS_24'
--	  Into #IFS
--From Provista..IFS_Member_Contract_Master
--Group By Company_ID, Member_ID





-----------Set Team Structure---------------
IF OBJECT_ID ('tempdb..#Team_Structure') IS NOT NULL
DROP TABLE #Team_Structure
select distinct [ActMgr_Fullname]
      ,[Teleserv_Fullname]
      ,[Division_ID]
      ,[Group_Leader]
     INTO #Team_Structure
  FROM [Provista].[dbo].[PRS_AcctMgr_Monthly_Fact]



  --------------Set Top Parent State---------------
  IF OBJECT_ID ('tempdb..#group_state') IS NOT NULL
DROP TABLE #group_state
select distinct PARENT_ID,PARENTSTATE
     INTO #group_state
  FROM [Provista].[dbo].[Member_Company_Provista]

  -------------Set Focused Members for Inside(Virtual) Sales----------
--  IF OBJECT_ID ('tempdb..#Focused') IS NOT NULL
--DROP TABLE #Focused
--Select MEM_ID__c
--Into #Focused
--From Provista..SF_Account
--where Pharmacy_Rep__c in ('Focused')

-- ------------Customer_Service_Rep-------------------
--    IF OBJECT_ID ('tempdb..#cs_rep') IS NOT NULL
--DROP TABLE #cs_rep
--Select distinct MEMBER_ID,  sfa.Customer_Service_Rep__c
--into #cs_rep
--from provista..Member_Company_Provista mcp
--left join provista..SF_Account sfa on mcp.MEMBER_ID = sfa.MEM_ID__c and mcp.COMPANY_ID = sfa.COID__c
--where Customer_Service_Rep__c is not null

-------------Set Procurement Member ID's-------------------
--IF OBJECT_ID ('tempdb..#Procurement') IS NOT NULL
--DROP TABLE #Procurement
--Select MEM_ID__c,Procurement_Group__c,Procurement_Program__c
--Into #Procurement
--From Provista..SF_Account
--where Procurement_Program__c is not null

  -------------Membership + Member Grouping + PRS + Team Structure + Top Parent State----------- 
IF OBJECT_ID ('tempdb..#Member_Summary') IS NOT NULL
DROP TABLE #Member_Summary

Select Distinct SF.Id,
concat(mcp.member_id,'-',mcp.COMPANY_ID) as memco
      ,MCP.[COMPANY_ID]
      ,MCP.[MEMBER_ID]
	  ,MCP.[MEMBER_NAME]
	  ,mcp.MEMBER_ADDRESS1
	  ,mcp.MEMBER_ADDRESS2
	  ,mcp.MEMBER_CITY
	  ,MCP.[MEMBER_STATE]
      ,MCP.[MEMBER_ZIP_CODE]
	  ,mcp.LIC
	  ,mcp.DEA_All
	  ,mcp.HIN_All
	
	  ,MCP.[SYSTEM_ID]
	  ,MCP.[SYSTEM_NAME] 
	  ,MCP.[SYSTEMSTATE] 
	  ,MCP.[SYSTEMZIPCODE]
	  
	  ,MCP.[PARENT_ID]
	  ,MCP.[PARENT_NAME]
	  ,MCP.[PARENTSTATE]
      ,MCP.[PARENTZIPCODE]
      
	  ,MCP.[Top_Parent_Company_ID]
      ,MCP.[Top_Parent_ID]
	  ,MCP.[Top_Parent_Name] 
	  --,gs.PARENTSTATE top_parent_state
	  
	  ,MCP.Prime_Type_Category_Desc
	  ,mcp.Specialty_Type_Desc
	  

      ,MCP.[SALES_INDICATOR] 
	  ,MCP.[SALESPCT]

      ,MCP.[LOFFICE_ID]
      ,MCP.[LOFFICE_NAME]
	  ,MCP.[LOFFICE_SUB_ID]
	  ,MCP.[LOFFICE_SUB_NAME]
      ,MCP.[TERRITORY_ID]
	  ,MCP.[TERRITORY_NAME]
	  ,MCP.[MEMBER_STATUS_DESC]
	  ,MCP.[MEMBER_START_DATE]
	  ,MCP.[MEMBER_TERM_DATE]
	  ,mcp.Report_ID
	  --,sf.Enrollment_Date__c

	  ,G.Group_Type
	  ,G.Group_Sub_Type
	  ,G.Group_Sub_Type_Cd
	  ,G.Group_Sub_Type_Name

	 --,p.CONTRACT_ID
	 --,p.VENDOR_NAME
	 -- ,Spend_Mgmt_Domain
	 --,PROD_SEG_ID

	  ,MCP.[DIVISION_ID] as 'Div_ID'
	  ,MCP.[DIVISION_NAME] as 'Div_Name'
      ,MCP.[ACTMGR_FULLNAME] as 'ACTMGR_FullName'
	  ,MCP.[Group_Leader] as 'Group_Leader'
	  ,MCP.[TELESERV_FULLNAME] as 'TS_Rep'
	  ,MCP.[Pharmacy_Rep] as 'RX_Rep'
      ,MCP.[Distribution_Rep] as 'Dist_Rep'
	  
	  ,SF.Customer_Service_Rep__c as 'CS_Rep'
	   
	   ,MCP.[Quota_Division_ID] as 'Quota_Div_ID'
	   ,MCP.[Quota_Division_Name]  as 'Quota_Div_Name'
	   ,MCP.[Quota_ActMgr_FullName] as 'Quota_ACTMGR_FullName'
	   ,MCP.[Quota_Group_Leader] as 'Quota_Group_Leader'
       ,MCP.[Quota_TS_FullName] as 'Quota_TS'
	   ,MCP.[Quota_Pharmacy_Rep] as 'Quota_RX'
       ,MCP.[Quota_Distribution_Rep] as 'Quota_Dist'

       ,sf.Division_ID_Quota__c as 'SF_Quota_Division_ID'
	   ,sf.Division_Name_Quota as 'SF_Quota_Division_Name'
	   ,sf.Account_Executive_Quota__c as 'SF_Quota_AE'
	   ,sf.Group_Leader_Quota__c as 'SF_Quota_Group_Leader'
	   ,sf.Sales_Leader_Quota__c as 'SF_Quota_Sales_Leader'
	   ,sf.Pharmacy_Rep_Quota__c as 'SF_Quota_Pharmacy_Rep'
	   ,sf.Distribution_Rep_Quota__c as 'SF_Quota_Distribution_Rep'

	   ,sf.Pharmacy_Rep__c as 'Focused'
	  

	   ,P.Rev_22_PRS GAF_22_TOTAL
	   ,P.Rev_23_PRS GAF_23_TOTAL
	   ,P.Rev_24_PRS GAF_24_TOTAL
	  

	   ,N.GRev_22
	   ,N.GRev_23
	   ,N.GRev_23_YTD
	   ,N.GRev_24

	   ,N.CNAF_Rev_22
	   ,N.CNAF_Rev_23_YTD
	   ,N.CNAF_Rev_24
	  ,N.CNAF_Rev_23_Total

	   --,I.FS_22
	   --,I.FS_23
	   --,I.FS_24

	   
	   
 
 ,CASE 
       WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NOT NULL THEN MCP.Top_Parent_ID 
	   WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NULL THEN MCP.MEMBER_ID  
	   when mcp.system_id in ('2821254','2643725','842123') then mcp.member_id ELSE MCP.SYSTEM_ID end as 'New_Grouping_ID'
,CASE 
       WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NOT NULL THEN MCP.Top_Parent_NAME 
	   WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NULL THEN MCP.MEMBER_NAME 
	   when mcp.system_id in ('2821254','2643725','842123') then mcp.MEMBER_NAME ELSE MCP.SYSTEM_NAME end as 'New_Grouping_Name'
--,CASE 
--       WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NOT NULL THEN gs.PARENTSTATE 
--	   WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NULL THEN MCP.member_state 
--	   when mcp.system_id in ('2821254','2643725','842123') then mcp.MEMBER_STATE ELSE mcp.SYSTEMSTATE end as 'New_Grouping_State'
--,CASE 
--       WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NOT NULL THEN gs.PARENTZIPCODE
--	   WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NULL THEN MCP.MEMBER_ZIP_CODE
--	   when mcp.system_id in ('2821254','2643725','842123') then mcp.MEMBER_ZIP_CODE ELSE mcp.SYSTEMZIPCODE end as 'New_Grouping_Zip'
,Case 
       when MCP.system_id in ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NOT NULL then 'Top_Parent' 
	   WHEN MCP.SYSTEM_ID IN ('74360','914766','1107686','2865736','2253351','3789004','927750') AND MCP.Top_Parent_ID IS NULL THEN 'Member'
	   when mcp.system_id in ('2821254','2643725','842123') then 'Member' else 'System' end as 'Less_Than_System_Split'

 
	-- ,case when mcp.SALES_INDICATOR = 'Y' and mcp.SALESPCT = 100 then 'Y-100' else null end as 'Y-100_Ind'
 ,case when p.Rev_22_PRS + Rev_23_PRS  <> 0 then 'Rev' else null end as 'rev_ind'
	-- ,case when mcp.DIVISION_ID = sf.Division_ID_Quota__c then 'SAME TEAM' else 'Team_Misalignment' end as 'Team_SAME_Test'
	-- ,case when mcp.ACTMGR_FULLNAME = sf.Account_Executive_Quota__c then 'SAME REP' else 'Rep_Misalignment' end as 'Rep_SAME_Test'
	 ,ts.ActMgr_Fullname as 'Plan_AE'
	,ts.Teleserv_Fullname as 'Plan_SL'
	 ,ts.Group_Leader as 'Plan_GL'
	 ,ts.Division_ID as 'Plan_Div_ID'
	 ,case when ts.ActMgr_Fullname is null then 'Fix' else 'ok' end as 'Quota_Team_Structure_Check'
	 --,EF.organizationNo,EF.facilityName,EF.facilityNo
	--,case when Group_Sub_Type_Cd in ('BMG','CWPG','EEMG','MDG','MDG1','MGPA','MGPG','MGPM','MHCX','PIPE','PSMA','PSNC','RHA','RHA2','RHA3','RHA4','RHA5','RHAP','THC') or SYSTEM_ID in ('3682441') then 'Austen Wood' 
	--when Group_Sub_Type_Cd in ('331X','BMTR','CONC','COOK','COR','EVRA','MEDC','NUTR','SQUA','TAL','VEIR') or SYSTEM_ID in ('2623570') then 'Blaire Bendian'
	--when Group_Sub_Type_Cd in ('AOA','CARE','CHA1','CHA9','CHCA','ENCH','ENT','MDVP','NCHC','NPHI','UNA','UNAG','USWH','VSG') then 'Katie Libner'
	--when Group_Sub_Type_Cd in ('BEST','UDA','COAC','HPA','HPA1') then 'Madison Bayless'
	--else null end as '2024_Channel_Partner_Owners'
	--,case when Group_Sub_Type_Cd in ('BMG','CWPG','EEMG','MDG','MDG1','MGPA','MGPG','MGPM','MHCX','PIPE','PSMA','PSNC','RHA','RHA2','RHA3','RHA4','RHA5','RHAP','THC') or SYSTEM_ID in ('3682441') and mcp.ACTMGR_FULLNAME in ('Austen Wood') then 'OK' 
	--when Group_Sub_Type_Cd in ('331X','BMTR','CONC','COOK','COR','EVRA','MEDC','NUTR','SQUA','TAL','VEIR') or SYSTEM_ID in ('2623570') and mcp.ACTMGR_FULLNAME in ('Blaire Bendian') then 'OK'
	--when Group_Sub_Type_Cd in ('AOA','CARE','CHA1','CHA9','CHCA','ENCH','ENT','MDVP','NCHC','NPHI','UNA','UNAG','USWH','VSG') and mcp.ACTMGR_FULLNAME in ('Katie Libner') then 'OK'
	--when Group_Sub_Type_Cd in ('BEST','UDA','COAC','HPA','HPA1') and mcp.ACTMGR_FULLNAME in ('Madison Bayless') then 'OK'
	--else 'Membership_Research' end as 'Channel_Partner_Owner_Test'
	--,pm.Quota_ActMgr_FullName as 'Primary_MID_Quota_Owner'
	--,pm.Quota_Division_ID
	--,pm.DIVISION_ID
	--,case when mcp.Quota_ActMgr_FullName = pm.Quota_ActMgr_FullName then 'ok' else 'check' end as 'Y-100_Analysis_Check'
	--,sf.Authorization_for_Data_Access__c
	--,sf.Supply_Analytics__c
	--,pm.Customer_Service_Rep__c Primary_CS_Rep
	--,sf.Customer_Service_Rep__c SF_CS_Rep
	--,c.Customer_Service_Rep__c Exp_CS_Rep
	--,sf.Account_Executive_Quota__c as 'SF_Quota_Rep'
	--,t.Quota_SL,t.Quota_GL,t.Quota_DivID

INTO #Member_Summary 

FROM [Provista].[dbo].[Member_Company] MCP
LEFT Join #MC_Group as G on MCP.MEMBER_ID = G.Member_ID and MCP.COMPANY_ID = G.Company_ID
LEFT Join #PRS as P on MCP.MEMBER_ID = P.MEMBER_ID and MCP.COMPANY_ID = P.COMPANY_ID
LEFT Join #PRS_NAF as N on MCP.MEMBER_ID = N.MEMBER_ID and MCP.COMPANY_ID = N.COMPANY_ID
--LEFT Join #IFS as I on MCP.MEMBER_ID = I.MEMBER_ID and MCP.COMPANY_ID = I.COMPANY_ID
--LEFT Join #PRS_NAF as 
LEFT JOIN [Provista].[dbo].[SF_Account] SF on MCP.COMPANY_ID = SF.COID__c and MCP.MEMBER_ID = SF.MEM_ID__c
left join #Team_Structure ts on sf.Account_Executive_Quota__c = ts.ActMgr_Fullname and sf.Sales_Leader_Quota__c = ts.Teleserv_Fullname and sf.Division_ID_Quota__c = ts.Division_ID and sf.Group_Leader_Quota__c = ts.Group_Leader
--left join #group_state as Gs on mcp.Top_Parent_ID = Gs.PARENT_ID
--Left Join #Focused F on MCP.MEMBER_ID = F.MEM_ID__c
--left join #primary_mid PM on mcp.MEMBER_ID = pm.MEMBER_ID
--Left Join #Procurement T on MCP.MEMBER_ID = T.MEM_ID__c
--left join [Provista_IOS].[dbo].[Envi_Facilities] EF on mcp.MEMBER_ID = EF.Member_ID
--left join #cs_rep c on mcp.MEMBER_ID = c.MEMBER_ID
--where (Mcp.COMPANY_ID = 019 or mcp.DIVISION_ID in ('P%') or Quota_Division_ID in ('P%'))
--where Quota_Division_ID like ('P%') and Quota_Division_ID not in ('PM','PU','PB')
--where Quota_ActMgr_FullName in ('Jennifer Burton','Tatiana Otto')
--where Quota_Division_ID in ('PM')


------ Data Pull From Master Table (Member_Summary)---------


--select * from #Member_Summary where CS_Rep IN ('Allyson Freeman', 'Andrea Allstun', 'Helena Silvia', 'Jennifer Geronaitis', 'Micah Schlick', 'Robin VanDyke', 'Sloan Fioresi', 'Sydney Litchfield')

select * from #Member_Summary where MEMBER_ID in ('44817','52058','52794','53474','53562','55325','61533','62592','69827','75119','80235','82565','82661','83206','83918','87452','89993','99294','99440','100465','103804','106154','109322','109437','112356','112380','707802','707820','711248','712659','713008','723924','767440','768853','791532','797131','806769','807436','814209','820539','821506','827790','828173','829942','834488','838300','839147','844808','845310','846809','857099','862037','875532','878909','885225','895217','897719','904285','912501','923198','923583','925907','929607','929808','932571','933027','933826','934797','937562','939509','940221','952133','954403','961653','963309','966675','968131','968755','981919','981953','982593','982612','982787','982893','983129','983932','984184','984525','986221','986472','986674','990366','992236','992966','993958','996580','1010503','1011943','1012211','1046344','1046505','1049134','1049514','1053672','1054226','1061438','1062748','1065367','1065444','1066804','1067070','1068889','1069507','1072755','1083751','1084762','1088571','1089203','1089386','1090283','1091349','1092492','1098115','1100561','1102776','1104230','1107048','1107527','1108205','1110767','1112912','1115797','1116439','1119751','1121801','1125583','1126612','1126875','1128446','1133402','1137776','1143332','1149137','1149663','1149772','1157969','1174243','1175363','1176374','1177131','1177240','1182739','1186955','2195517','2226872','2227108','2253033','2272206','2284439','2284551','2294201','2294246','2294482','2294580','2393670','2409849','2410356','2419749','2439547','2442092','2443718','2444654','2445879','2446102','2450726','2466817','2472206','2483914','2488750','2576529','2577200','2577232','2582691','2595071','2598997','2602998','2603692','2605198','2608761','2609058','2614883','2616436','2616442','2621459','2623234','2629407','2630279','2631095','2634575','2635441','2637375','2637679','2639211','2642699','2650400','2650968','2651096','2672029','2678221','2678246','2678378','2679678','2688536','2688594','2741912','2782825','2784934','2785030','2786853','2787359','2787434','2787949','2788079','2788262','2788519','2788764','2791614','2791892','2791950','2792028','2792054','2792140','2792303','2793264','2793494','2793560','2793770','2794641','2794669','2794800','2795347','2795627','2795835','2795921','2795929','2796440','2797605','2797898','2798268','2798308','2798362','2798479','2798626','2798627','2798805','2799198','2800514','2800629','2801160','2801308','2801390','2801493','2802259','2802952','2803072','2803093','2803329','2809412','2809722','2812182','2812403','2813697','2814201','2814218','2814274','2816896','2820875','2821811','2821956','2821997','2822047','2824293','2824516','2826762','2829318','2835666','2837708','2851326','2858215','2860338','2864533','2864814','2866172','2866345','2866843','2888384','2888477','2888745','2895276','2899619','2916586','2954968','2959796','2962531','2966287','2970019','2972966','2980935','2981073','2991669','2998119','3005045','3021836','3022762','3038326','3039098','3039305','3084125','3189471','3200022','3209960','3212900','3236860','3239778','3240456','3247663','3255597','3258912','3263619','3263634','3263639','3272776','3297949','3298179','3301635','3322345','3327319','3345826','3347218','3349005','3350465','3364219','3370248','3370287','3370765','3382374','3392185','3403719','3403721','3403847','3409771','3477946','3485141','3485540','3499123','3507262','3509068','3509945','3515746','3516712','3517782','3557328','3561007','3567078','3601258','3610615','3615115','3626326','3635369','3663708','3682732','3693015','3695433','3712225','3725466','3730946','3737086','3744889','3751084','3784320','3788586','3793957','3793972','3794462','3794627','3794639','3817523','3820103','3827062','3852606','3948260','3949872','3950254','3950392','3951014','3951695','3952333','3952648','3953304','3953559','3954233','3954264','3954618','3954829','3954854','3955453','3956321','3956611','3956727','3956759','3957145','3957343','3957489','3958052','3958363','3958590','3958594','3958620','3959124','3959458','3959673','3959768','3960307','3961529','3961976','3962070','3963080','3963147','3964210','3964262','3964377','3964431','3964492','3964544','3964718','3965119','3965136','3965472','3965559','3965562','3966120','3966222','3966707','3966724','3967034','3967072','3967809','3967853','3967873','3968249','3968906','3969086','3969096','3969350','3969827','3969912','3969990','3970340','3970552','3970779','3970941','3970977','3971018','3971020','3971066','3971102','3971189','3971305','3971375','3971485','3971956','3972320','3972732','3972764','3972769','3973172','3973522','3973622','3973988','3974001','3974024','3974276','3974302','3974467','3974494','3974655','3974939','3975208','3975351','3975385','3975404','3975443','3975565','3976216','3976577','3976687','3977193','3977258','3977383','3977404','3977435','3977816','3977886','3977988','3978293','3978473','3978987','3979207','3979783','3979873','3979890','3986070','3987276','3988352','3998023','4014174','4014754','4019116','4019231','4022420','4022745','4023167','4024590','4027582','4029033','4032184','4042274','4050542','4051393','4065421','4067238','4072864','4087740','4109969','4133375','4134368','4136722','4141331','4155814','4164027','4168945','4183981','4190857','4201220','4210308','4219096','4220280','4274404','4297091','4302374','5981975','5989788','6005329','6008374','6010308','6011988','6016179','6031754','6044539','6050141','6076758','6086058','6104406','6109162')


--select * from #Member_Summary where SF_Quota_Division_ID in ('PI')

--select * from #Member_Summary where SF_Quota_Distribution_Rep is not null

--select * from #Member_Summary where Group_Sub_Type_Cd in ('EEMG')

--select * from #Member_Summary where Top_Parent_ID in ('3737427') 

--select Quota_Div_ID,sum(rev_24_prs) from #Member_Summary group by Quota_Div_ID --where Group_Sub_Type_Cd in ('EEMG')

--select * from #Member_Summary where MEMBER_ID in ('1028489') order by COMPANY_ID--and Quota_ACTMGR_FullName not in ('mahmood umer')

--select * from #Member_Summary where Quota_Team_Structure_Check in ('fix') and Div_ID like ('P%') and COMPANY_ID not in ('052','055','020')



--select * from #Member_Summary where Quota_ACTMGR_FullName in ('Allyson Freeman') --and Group_Sub_Type_Cd is not null

--select * from #Member_Summary where MEMBER_ID in ('1103364')







---------------------------------------------check overall rep assignmnet---------------
--IF OBJECT_ID ('tempdb..#Member_Summary2') IS NOT NULL
--DROP TABLE #Member_Summary2

--select --SF_Quota_AE,SF_Quota_Division_ID,SF_Quota_Sales_Leader,SF_Quota_Group_Leader--,new_grouping_id,new_grouping_name,
----Group_Sub_Type_Cd,Group_Sub_Type_Name,
----Quota_ACTMGR_FullName,
----New_Grouping_ID,New_Grouping_Name--,Quota_ACTMGR_FullName

--Quota_ACTMGR_FullName,Quota_Div_ID,New_Grouping_ID,New_Grouping_Name
----sum(Rev_22_YTD) rev_22
----,
----,sum(GAF_22_TOTAL) GAF_22_TOTAL 
----,sum(GAF_23_TOTAL) GAF_23_TOTAL
----,sum(GAF_24_TOTAL) GAF_24_TOTAL
 
----,sum(FS_22) FS_22 
----,sum(FS_23) FS_23
----,sum(FS_24) FS_24

----,
----,sum(GRev_22) rev_22 
--,sum(GRev_23) rev_23 
--,sum(GRev_23_YTD) rev_23_YTD
--,sum(GRev_24) rev_24 

----,sum(CNAF_Rev_22) NAF_22 
--,SUM(CNAF_Rev_23_Total) CNAF_23
--,sum(CNAF_Rev_23_YTD) NAF_23_YTD
--,sum(CNAF_Rev_24) NAF_24

--Into #member_summary2

--from #Member_Summary 
----where  Quota_Div_ID in ('PM') --and SF_Quota_Division_ID not in ('PM','PB','PG','PU','PE') --and Rev_22_PRS+Rev_23_PRS<>0
--group by Quota_ACTMGR_FullName,Quota_Div_ID,New_Grouping_ID,New_Grouping_Name
----SF_Quota_AE,SF_Quota_Division_ID,SF_Quota_Sales_Leader,SF_Quota_Group_Leader--,new_grouping_id,new_grouping_name,
----Group_Sub_Type_Cd,Group_Sub_Type_Name,
----Quota_ACTMGR_FullName,
----New_Grouping_ID,New_Grouping_Name--,Quota_ACTMGR_FullName
----Quota_Div_ID
----order by --SF_Quota_Division_ID,SF_Quota_Group_Leader,SF_Quota_AE

----select * from #member_summary2

--select distinct * from #member_summary2 where (rev_23 + rev_24 <> 0) or (CNAF_23 + NAF_24 <> 0) --or CNAF_23 <> 0



