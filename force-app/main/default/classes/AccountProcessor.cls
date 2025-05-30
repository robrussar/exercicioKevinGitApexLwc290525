public with sharing class AccountProcessor {
    
    @AuraEnabled(cacheable=false)
    public static List<Account> getAccountsAndUpdateType() {
        // Query only accounts with Type field populated
        List<Account> accounts = [SELECT Id, Name, Type, Description, Active__c 
                                 FROM Account 
                                 WHERE Type != null];
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            // Adicionar mensagem à descrição
            acc.Description = (acc.Description != null ? acc.Description + ' - ' : '') + 'Alterado por Robert Russar';
            
            // Definir Active__c como true (assumindo que é um campo booleano)
            acc.Active__c = 'Yes';
            
            // Verificar e modificar o Type conforme regra
            if (acc.Type == 'Customer - Direct') {
                acc.Type = 'Customer - Kevin';
            } else {
                acc.Type = 'Customer - Channel';
            }
            
            accountsToUpdate.add(acc);
        }
        
        // Atualizar os registros no banco de dados
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            } catch (Exception e) {
                System.debug('Erro ao atualizar contas: ' + e.getMessage());
                throw new AuraHandledException('Erro ao atualizar contas: ' + e.getMessage());
            }
        }
        
        // Retornar os registros atualizados
        return accountsToUpdate;
    }
}