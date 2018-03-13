using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WMPT.Infrastructure
{
    public static class Urls
    {
        public static string redirect_uri = @"https://peaceful-headland-89963.herokuapp.com";
        public static string ShouQuan = @"https://dopen.weimob.com/fuwu/b/oauth2/authorize?enter=wm&view=pc&response_type=code&scope=default&client_id={0}&redirect_uri={1}&state=HYWMPT";
        public static string GetAccessToken =
            @"https://dopen.weimob.com/fuwu/b/oauth2/token?code={0}&grant_type=authorization_code&client_id={1}&client_secret={2}&redirect_uri={3}";

        public static string GetWMUserInfo =
            @"http://dopen.weimob.com/api/1_0/open/usercenter/getWeimobUserInfo?accesstoken={0}";

        public static string RefreshAccessToken = @"https://dopen.weimob.com/fuwu/b/oauth2/token?grant_type=refresh_token&client_id={0}&client_secret={1}&refresh_token={2}";


        //public string GetOffLineMemberInfoPageListAndTotal = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/GetOffLineMemberInfoPageListAndTotal?accesstoken={0}";

        public static string GetPointsLogPageListAndTotal =
            @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/GetPointsLogPageListAndTotal?accesstoken={0}";
        public static string GetMemberInfo = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/GetMemberInfo?accesstoken={0}";


        public static string ChangeMemberPoints = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/ChangeMemberPoints?accesstoken={0}";
        //public string SaveMemberInfo = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/SaveMemberInfo?accesstoken={0}";
        public static string AddOfflineMemberInfo = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/AddOfflineMemberInfo?accesstoken={0}";
        public static string UpdateOfflineMemberInfo = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/UpdateOfflineMemberInfo?accesstoken={0}";
    }

}