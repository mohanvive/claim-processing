
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client dbClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    port = dbPort
);
