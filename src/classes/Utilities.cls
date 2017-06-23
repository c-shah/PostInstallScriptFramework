/**
 * Created by cshah on 6/23/2017.
 */

/**
 * utilities is accessing system classes, needs without sharing
 */
public without sharing class Utilities {
    public static String getNamespace() {
        ApexClass cs =[select NamespacePrefix from ApexClass where Name = 'PostInstallService'];
        String nameSpacePrefix = cs.NamespacePrefix;
        return nameSpacePrefix;
    }
}