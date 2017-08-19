using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using Massive;

namespace WMPT.Models
{
    public class Users : DynamicModel
    {
        public Users()
            : base("HYDB", "WMUSERS", "ID", "NAME", "WMUSERS_ID_SEQ")
        {

        }

        public dynamic Register(string name, string password, string confirm)
        {
            dynamic result = new ExpandoObject();
            result.Success = false;
            if (name.Length >= 2 && password.Length >= 6 && password.Equals(confirm))
            {
                try
                {
                    result.User = this.Insert(new { NAME = name, HashedPassword = Hash(password) });
                    result.Success = true;
                    result.Message = "Thanks for signing up!";
                }
                catch (Exception ex)
                {
                    result.Message = "This email already exists in our system";
                }
            }
            else
            {
                result.Message = "Please check your email and password - they're invalid";
            }
            return result;
        }
        public static string Hash(string userPassword)
        {
            return
                BitConverter.ToString(SHA1Managed.Create().ComputeHash(Encoding.Default.GetBytes(userPassword))).Replace
                    ("-", "");
        }

        public void SetToken(string token, dynamic user)
        {
            this.Update(new { Token = token }, user.ID);
        }


        public dynamic Login(string name, string password)
        {
            dynamic result = new ExpandoObject();

            result.User = this.Single(" name = :0 AND hashedpassword = :1", name, Hash(password));
            result.Authenticated = result.User != null;

            if (!result.Authenticated)
                result.Message = "Invalid email or password";

            return result;
        }


        public static dynamic FindByToken(string token)
        {
            var db = new Users();
            return db.Single(where: "Token = :0", args: token);
        }
    }
}